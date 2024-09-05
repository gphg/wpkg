# Wget Package Manager

Small shell script that downloads files given in a text file via ```wget``` and
verifies the downloaded files via the given expected hash checksums.

By default the script uses a ```package.txt``` in the current directory. The
format of the package list file is:

```
<DOWNLOAD_URL>	<TARGET_FILENAME>	<HASH_ALGO>:<EXPECTED_HASH_CHECKSUM>
```

Have a look at the [package.txt](package.txt) file in this repository for an
example. Lines starting with `#` are comment lines and will be stripped prior
to line-by-line interpretation of the file.

You can customize the packages file path by setting an environment variable
named ```WGET_PACKAGES_FILE```:

```sh
WGET_PACKAGES_FILE=path/to/your/file wpkg.sh
```

Please contribute by [forking](http://help.github.com/forking/) and sending a
[pull request](http://help.github.com/pull-requests/). The license is MIT.
