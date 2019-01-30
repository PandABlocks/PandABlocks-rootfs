#!/usr/bin/env python
import logging.handlers
import subprocess
import glob
import os
import sys
import mimetypes
from collections import defaultdict, OrderedDict

from tornado.ioloop import IOLoop
from tornado.template import Loader
from tornado.process import Subprocess
from tornado.escape import xhtml_escape
from tornado.gen import coroutine
from tornado.iostream import StreamClosedError
from tornado.web import RequestHandler, Application, StaticFileHandler, \
    HTTPError

# Some paths
OPT_ETC = "/opt/etc/www"
OPT_SHARE_WWW = "/opt/share/www"
TEMPLATES = "/usr/share/web-admin/templates"
STATIC = "/usr/share/web-admin/static"
AUTHORIZED_KEYS = "/boot/authorized_keys"
LOG_FILE = "/var/log/web-admin.log"
MNT = "/mnt"
ROOTFS_VERSION = os.path.join(os.path.dirname(__file__), "rootfs-version.sh")
ROOTFS = '/boot/imagefile.cpio.gz'

# Log to a rotating file
file_handler = logging.handlers.RotatingFileHandler(
    LOG_FILE, maxBytes=1000000, backupCount=4)
logging.root.addHandler(file_handler)
logging.root.setLevel(logging.INFO)
logging.info("Loading web-admin...")

# Add mimetype for SVG
mimetypes.types_map[".svg"] = 'image/svg+xml'

# A loader for files in OPT_ETC
etc_loader = Loader(OPT_ETC)

# The admin drawer
drawer = OrderedDict()
drawer["system"] = ("System", OrderedDict())
drawer["packages"] = ("Packages", OrderedDict())
drawer["ssh"] = ("SSH Keys", OrderedDict())

# The get_pages with a decorator to add to them
get_pages = OrderedDict()


class PrintableError(Exception):
    pass


def add_get_page(p):
    def decorator(func):
        get_pages[p] = func
        if p is not None:
            section, name = p.split("/")
            drawer[section][1][name] = func.__doc__
        return func
    return decorator


# The post_pages with a decorator to add to them
post_pages = OrderedDict()


def add_post_page(p):
    def decorator(func):
        func = coroutine(func)
        post_pages[p] = func
        return func
    return decorator


# Simple validation: just check for presence of mounted usb device
def ensure_usb_key_inserted():
    if subprocess.call(['grep', '-q', ' /mnt/sd.*', '/proc/mounts']) != 0:
        raise PrintableError(
            "A USB stick must be inserted into the device to perform this "
            "operation. This is for security reasons so physical access to "
            "the device is ensured.")


def tt(text):
    return "<samp>%s</samp>" % xhtml_escape(text)


def glob_dir(g, *path_suffix):
    root = os.path.join(MNT, *path_suffix)
    glob_list = [x[len(root):] for x in glob.glob(root + g)]
    return root, glob_list


def blocking_cmd_lines(*cmd):
    return subprocess.Popen(cmd, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT).stdout.readlines()


class RedirectError(Exception):
    pass


class CommandHandler(RequestHandler):
    def t(self, template, **kwargs):
        self.write(self.render_string(template, **kwargs))

    def p(self, text):
        self.write("<p>%s</p>" % text)

    def h2(self, text):
        self.write("<h2>%s</h2>" % text)

    def command_row(self, text):
        self.write('<div class="command-row">%s</div>' % xhtml_escape(text))

    def popup(self, href, text):
        self.write('<a target="_blank" rel="noopener noreferrer" href="%s">%s'
                   '</a>' % (href, text))

    @coroutine
    def run_command(self, *command):
        got_output = False
        self.flush()
        sub_process = Subprocess(
            command, stdout=Subprocess.STREAM, stderr=subprocess.STDOUT)
        try:
            while True:
                line = yield sub_process.stdout.read_until("\n")
                if not got_output:
                    got_output = True
                    self.write('<div class="shadow command">')
                self.command_row(line)
                self.flush()
        except StreamClosedError:
            if got_output:
                self.write('</div>')

    @coroutine
    def sync(self):
        self.p('Writing state to disk...')
        yield self.run_command('sync')

    @coroutine
    def zpkg(self, action, *packages):
        if packages:
            package_strings = ", ".join(tt(x) for x in packages)
            self.p("About to %s %s..." % (action, package_strings))
            yield self.run_command("zpkg", action, *packages)
            yield self.sync()
            self.p("Package %s operation complete." % action)
        else:
            self.p("Nothing to %s." % action)

    def list_package_instructions(self):
        self.p("Packages have file extension .zpg and are downloaded from a "
               "GitHub release of the relevant repository:")
        self.write("<ul>")
        for repo in ("PandABlocks-FPGA", "PandABlocks-server",
                     "PandABlocks-webcontrol"):
            link = "https://github.com/PandABlocks/%s/releases" % repo
            self.write("<li>")
            self.popup(link, repo)
            self.write("</li>")
        self.write("</ul>")

    def show_ssh_help(self):
        self.write("<p>")
        self.write("SSH access is only allowed to users who have placed their ")
        self.popup("https://www.ssh.com/ssh/authorized-key", "Authorized key")
        self.write(" on this device")
        self.write("</p>")

    def list_dir(self, *path_suffix):
        root = os.path.join(MNT, *path_suffix)
        dirs = [f + "/" for f in os.listdir(root)
                if os.path.isdir(os.path.join(root, f))
                and not os.path.islink(os.path.join(root, f))]
        if len(path_suffix) > 1:
            dirs.append("../")
        if dirs:
            self.h2("Select a directory to browse:")
            self.write("<ul>")
            for d in sorted(dirs):
                self.write('<li><a href="%s">%s</a></li>' % (d, d))
            self.write("</ul>")
        return dirs

    def list_file(self, fname):
        self.write('<div class="shadow command">')
        with open(fname) as f:
            for line in f:
                self.command_row(line)
        self.write('</div>')

    def select_glob(self, g, label, *path_suffix):
        root = os.path.join(MNT, *path_suffix)
        glob_list = [x[len(root):] for x in glob.glob(root + g)]
        if glob_list:
            self.h2("Available in %s:" % tt(root))
            self.t("form_select.html", label=label, titles=glob_list, path="./")
        return glob_list

    def ensure_trailing_slash(self):
        if not self.request.path.endswith("/"):
            self.redirect(self.request.path + "/")
            raise RedirectError()

    # The get pages
    @add_get_page(None)
    def get_admin(self):
        """Administration"""
        self.h2("Version information")
        self.list_file('/etc/version')
        self.p("Use the side-bar on the left to access the Admin functions")

    @add_get_page("system/restart")
    def get_reboot_restart(self):
        """Reboot/Restart"""
        self.p("Use this option to restart any service provided by a package")
        self.t('button.html', label='Restart services', path='system/restart')
        self.p("Use this option to restart the box")
        self.t('button.html', label='Reboot now', path='system/reboot')

    @add_get_page("system/log")
    def get_log_messages(self):
        """Show /var/log/messages"""
        self.list_file('/var/log/messages')

    @add_get_page("system/network")
    def get_network_config(self):
        """Show Network Configuration"""
        boot_config = open('/tmp/config_file').read()[:-1]
        self.p("Configuration loaded from " + tt(boot_config))
        self.h2("Configuration in " + tt("/boot/config.txt"))
        self.list_file('/boot/config.txt')
        new_config = glob.glob('/mnt/*/panda-config.txt')
        if new_config:
            new_config = new_config[0]
            self.h2("Configuration in " + tt(new_config))
            self.list_file(new_config)
            self.t('button.html', label='Replace network configuration',
                   path='system/replace_network', value=new_config)

    @add_get_page("packages/list")
    def get_packages_list(self):
        """List Installed Packages"""
        self.list_package_instructions()
        self.p("The following packages are already installed")
        zpkg_list = sorted(blocking_cmd_lines('zpkg', 'list'))
        if zpkg_list:
            details = {}
            for line in zpkg_list:
                pkg = line.split()[0]
                details[line] = blocking_cmd_lines('zpkg', 'show', pkg)
            self.t("form_select.html", label="Delete Selected Packages",
                   path="/admin/packages/remove", titles=zpkg_list,
                   details=details)
        else:
            self.p("No packages installed")

    @add_get_page("packages/install")
    def get_packages_install(self, *path_suffix):
        """Install Packages from USB"""
        self.ensure_trailing_slash()
        self.list_package_instructions()
        self.p("Packages placed on the USB stick can be navigated to below.")
        root, glob_list = glob_dir('*.zpg', *path_suffix)
        if glob_list:
            self.h2("Available in %s:" % tt(root))
            self.t("form_select.html", label="Install Selected Packages",
                   titles=glob_list, path="./")
        dirs = self.list_dir(*path_suffix)
        if not dirs and not glob_list:
            self.p('No packages to install or sub-directories to browse')

    @add_get_page("packages/rootfs")
    def get_rootfs_install(self, *path_suffix):
        """Install Rootfs from USB"""
        self.ensure_trailing_slash()
        self.write("<p>")
        self.write("Updated rootfs images can be installed by placing the "
                   "imagefile.cpio.gz file from the boot.zip ")
        link = "https://github.com/PandABlocks/PandABlocks-rootfs/releases"
        self.popup(link, "rootfs release")
        self.write(" onto the USB stick, and navigating to it below.")
        self.write("</p>")
        root, glob_list = glob_dir('*.cpio.gz', *path_suffix)
        if glob_list:
            self.h2("Available in %s:" % tt(root))
            self.t("form_select.html", label="Replace rootfs on next reboot",
                   titles=glob_list, path="./")
        dirs = self.list_dir(*path_suffix)
        if not dirs and not glob_list:
            self.p('No rootfs to install or sub-directories to browse')

    @add_get_page("ssh/list")
    def get_ssh_list(self):
        """Show Authorised SSH Keys"""
        self.show_ssh_help()
        if os.path.isfile(AUTHORIZED_KEYS):
            self.list_file(AUTHORIZED_KEYS)
            self.t('button.html', label='Remove all authorized keys',
                   path='ssh/remove')
        else:
            self.p('No SSH keys authorized')

    @add_get_page("ssh/append")
    def get_ssh_append(self, *path_suffix):
        """Append SSH keys from USB"""
        self.ensure_trailing_slash()
        self.show_ssh_help()
        root, glob_list = glob_dir('authorized_keys', *path_suffix)
        if glob_list:
            self.h2("Available in %s:" % tt(root))
            details = {glob_list[0]:
                           open(os.path.join(root, glob_list[0])).readlines()}
            self.t("form_select.html", label="Append to authorized keys",
                   titles=glob_list, details=details, path="./")
        dirs = self.list_dir(*path_suffix)
        if not dirs and not glob_list:
            self.p('No authorized_keys found or sub-directories to browse')

    @add_post_page("system/reboot")
    def post_reboot(self):
        """Rebooting System"""
        yield self.sync()
        self.p("Rebooting now, please wait. "
               "This page will refresh in 30 seconds...")
        self.write('<meta http-equiv="refresh" content="30;url=/admin.html">')
        yield self.run_command('reboot')

    @add_post_page("system/restart")
    def post_restart(self):
        """Restarting Services"""
        self.p("Restarting services provided by packages...")
        yield self.run_command('/etc/init.d/zpkg-daemon', 'restart')
        self.p("Operation complete")

    def single_filename_argument(self, text):
        filenames = self.get_arguments('value')
        if len(filenames) != 1:
            if filenames:
                raise PrintableError(
                    "Cannot proceed, more than one %s selected" % text)
            else:
                raise PrintableError("No %s selected to install" % text)
        else:
            return filenames[0]

    @add_post_page("system/replace_network")
    def post_replace_network(self):
        """Replacing Network Configuration"""
        ensure_usb_key_inserted()
        new_config = self.single_filename_argument("network configuration")
        self.p("Replacing %s with %s..." % (tt("/boot/config.txt"),
                                            tt(new_config)))
        yield self.run_command('cp', new_config, '/boot/config.txt')
        yield self.sync()
        self.p("Operation complete")

    @add_post_page("packages/remove")
    def post_packages_remove(self):
        """Removing packages"""
        ensure_usb_key_inserted()
        packages = [x.split()[0] for x in self.get_arguments('value')]
        yield self.zpkg("remove", *packages)

    @add_post_page("packages/install")
    def post_packages_install(self, *path_suffix):
        """Installing packages"""
        ensure_usb_key_inserted()
        root = os.path.join(MNT, *path_suffix)
        packages = [os.path.join(root, f) for f in self.get_arguments('value')]
        yield self.zpkg("install", *packages)

    @add_post_page("packages/rootfs")
    def post_rootfs_install(self, *path_suffix):
        """Preparing Updated Rootfs"""
        ensure_usb_key_inserted()
        new_rootfs = self.single_filename_argument("rootfs")
        path_suffix += (new_rootfs,)
        source_path = os.path.join(MNT, *path_suffix)
        self.p("Checking new rootfs version...")
        yield self.run_command(ROOTFS_VERSION, source_path)
        self.p("Copying %s to %s..." % (tt(source_path), tt(ROOTFS)))
        yield self.run_command('cp', source_path, ROOTFS)
        self.p("Checking md5sums match...")
        source_md5 = blocking_cmd_lines('md5sum', source_path)[0].split()[0]
        dest_md5 = blocking_cmd_lines('md5sum', ROOTFS)[0].split()[0]
        if source_md5 != dest_md5:
            os.remove(ROOTFS)
            self.p("Rootfs did not copy correctly, please try again")
        else:
            self.p(
                "Rootfs copied successfully to SD card. If you restart now it "
                "will be installed on boot. If you have changed your mind you "
                "can delete the new rootfs from the SD card and cancel.")
            self.t('button.html', label='Delete new rootfs and cancel',
                   path='packages/delete_rootfs')
            self.t('button.html', label='Reboot and install it now',
                   path='system/reboot')

    @add_post_page("packages/delete_rootfs")
    def post_delete_rootfs(self):
        """Delete the new Rootfs from the SD Card and Cancel"""
        ensure_usb_key_inserted()
        self.p("Removing %s" % tt(ROOTFS))
        yield self.run_command('rm', ROOTFS)
        yield self.sync()
        self.p("Rootfs upgrade successfully cancelled.")

    @add_post_page("ssh/remove")
    def post_remove_keys(self):
        """Removing SSH keys"""
        ensure_usb_key_inserted()
        self.p("Removing %s" % tt(AUTHORIZED_KEYS))
        yield self.run_command('rm', AUTHORIZED_KEYS)
        yield self.sync()
        self.p("All SSH keys removed. No-one will be able to login over SSH.")

    @add_post_page("ssh/append")
    def post_append_keys(self, *path_suffix):
        """Appending SSH keys"""
        ensure_usb_key_inserted()
        path_suffix += (self.get_argument('value'),)
        new_keys = os.path.join(MNT, *path_suffix)
        self.p("Adding keys from %s" % tt(new_keys))
        with open(AUTHORIZED_KEYS, "a") as existing_f:
            with open(new_keys) as new_f:
                existing_f.write(new_f.read())
        yield self.sync()
        self.p("SSH keys successfully added.")

    def start_admin_page(self, path, pages):
        checked = defaultdict(lambda: "")
        if path is None:
            command = None
            args = ()
        else:
            bits = path.split("/")
            checked[bits[0]] = "checked"
            command = "/".join(bits[:2])
            args = bits[2:]
        try:
            func = pages[command]
        except KeyError:
            raise HTTPError(404)
        self.t("header.html", title=func.__doc__, indented=True)
        self.t("nav.html", active="admin", etc_loader=etc_loader)
        self.t("drawer.html", drawer=drawer, checked=checked)
        self.write('<div class="content indented">')
        return func, args

    def end_admin_page(self):
        self.write('</div>')
        self.render("footer.html")

    def get(self, path=None):
        func, args = self.start_admin_page(path, get_pages)
        try:
            func(self, *args)
        except RedirectError:
            return
        self.end_admin_page()

    @coroutine
    def post(self, path):
        func, args = self.start_admin_page(path, post_pages)
        try:
            yield func(self, *args)
        except PrintableError as e:
            self.p(str(e))
        self.end_admin_page()


class TemplateHandler(RequestHandler):
    def get(self, path):
        if not path:
            path = "index.html"
        self.render(path, etc_loader=etc_loader)


class IdleApplication(Application):
    timeout_handle = None

    def reset_timeout(self):
        loop = IOLoop.current()
        if self.timeout_handle is not None:
            loop.remove_timeout(self.timeout_handle)
        # Run for 10 minutes then exit
        self.timeout_handle = loop.call_later(600, loop.stop)

    def start_request(self, server_conn, request_conn):
        self.reset_timeout()
        return super(IdleApplication, self).start_request(
            server_conn, request_conn)


# Start the application
app = IdleApplication([
    (r"/(|index\.html|docs\.html)", TemplateHandler),
    (r"/admin\.html", CommandHandler),
    (r"/admin/(.*)", CommandHandler),
    (r"/opt/(.*)", StaticFileHandler, {"path": OPT_SHARE_WWW})
], template_path=TEMPLATES, static_path=STATIC)
app.listen(8080)
app.reset_timeout()

if os.fork():
    # Exit first parent
    sys.exit(0)

# Do second fork to avoid generating zombies
if os.fork():
    sys.exit(0)

IOLoop.current().start()
