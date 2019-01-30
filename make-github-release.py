#!/bin/env python
import os
import sys
import urllib2
import json
import argparse
import re


TOKEN_FILE = os.path.expanduser("~/.config/panda-github-token")
CONTENT_TYPES = {
    ".zip": "application/zip",
    ".zpg": "application/gzip"
}
# Very restrictive release numbering: e.g. 1.0.2a92
RELEASE_RE = re.compile("[0-9]+(\.[0-9])*[abc]?[0-9]*$")

# Check for a token from a file
if os.path.exists(TOKEN_FILE):
    with open(TOKEN_FILE) as token_f:
        token = token_f.read().strip()
else:
    print >> sys.stderr, \
        "Please visit https://github.com/settings/tokens and generate a token" \
        "Copy this token into $TOKEN_FILE, e.g." \
        "    echo TOKEN_STRING_GOES_HERE > $TOKEN_FILE"
    sys.exit(1)


def token_request(base, path):
    full_path = "%s/%s" % (base, path)
    request = urllib2.Request(full_path)
    request.add_header("Authorization", "token %s" % token)
    return request


def api(path, data=None):
    request = token_request("https://api.github.com", path)
    if data:
        request.add_data(data)
    f = urllib2.urlopen(request)
    d = json.loads(f.read())
    return d


def make_release(repo, tag):
    path = "repos/PandABlocks/%s/releases" % repo
    for release in api(path):
        assert release["tag_name"] != tag, \
            "There is already a release made for %s for tag %s" % (repo, tag)
    d = api(path, json.dumps({"tag_name": tag}))
    assert "id" in d, "Cannot create release: %s" % d
    print "Created https://github.com/PandABlocks/%s/releases/tag/%s" % (
        repo, tag)
    return d["id"]


def upload(asset, repo, release_id):
    fname = os.path.basename(asset)
    ext = os.path.splitext(fname)[1]
    path = "repos/PandABlocks/%s/releases/%s/assets?name=%s" % (
        repo, release_id, fname)
    request = token_request("https://uploads.github.com", path)
    request.add_header("Accept", "application/vnd.github.manifold-preview")
    request.add_header("Content-Type", CONTENT_TYPES[ext])
    with open(asset, 'rb') as f:
        request.add_data(f.read())
    f = urllib2.urlopen(request)
    d = json.loads(f.read())
    assert "name" in d, "Cannot upload %s to release: %s" % (fname, d)
    print "Added %s to release" % d["name"]


def main():
    parser = argparse.ArgumentParser(
        description="Make a github binary release of a PandABlocks repo from a tag")
    parser.add_argument(
        "repo", help="Repo name (like PandABlocks-FPGA)")
    parser.add_argument(
        "tag", help="Name of an existing git annotated tag (like 1.0)")
    parser.add_argument(
        "files", metavar="F", nargs="+", help="Zip and ZPKG files to upload")
    args = parser.parse_args()
    assert RELEASE_RE.match(args.tag), \
        "Git version %s doesn't look like a x.y.z release number" % args.tag
    release_id = make_release(args.repo, args.tag)
    for asset in args.files:
        upload(asset, args.repo, release_id)


if __name__ == '__main__':
    main()
