# github-url-resolver package

Resolves a github URL to a markdown link.

![url-resolve](https://cloud.githubusercontent.com/assets/69169/12593071/0c90daf4-c424-11e5-92ad-5746372c859c.gif)

Parses the following formats:

```
username/repo#234
github.com/username/repo/pull/234
github.com/username/repo/issues/234
https://github.com/username/repo/pull/234
https://github.com/username/repo/issues/234
```

### Private repo access

Creating an access token (read only!) and setting it in the `GITHUB_ACCESS_TOKEN` environment variable will allow this to work on private github repos.
