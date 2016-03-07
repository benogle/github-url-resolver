GithubApi = require 'github'
GitHubURLRegex = new RegExp("(?:(?:https?://)?github.com/([^/\\s]+)/([^/\\s]+)/(?:pull|issues)/(\\d+))|(?:([\\w0-9_-]+)/([^#\\s]+)#(\\d+))", "g")

github = new GithubApi
  version: '3.0.0',
  timeout: 10000,
  protocol: 'https'

authenticate = () ->
  if process.env['GITHUB_ACCESS_TOKEN']
    github.authenticate
      type: "oauth",
      token: process.env['GITHUB_ACCESS_TOKEN']

module.exports =
  resolveURLsInString: (text) ->
    urls = @extractURLs(text)
    @fetchTitles(urls).then (titles) ->
      text.replace GitHubURLRegex, (wholeMatch) ->
        "[#{titles[wholeMatch]}](#{urls[wholeMatch].url})"

  fetchTitles: (matches) ->
    titles = {}
    promises = []
    for match, issueData of matches
      do (match, issueData) =>
        promises.push @fetchTitle(issueData).then (title) -> titles[match] = title

    Promise.all(promises).then -> titles

  fetchTitle: (issueData) ->
    new Promise (resolve, reject) ->
      authenticate()
      github.issues.getRepoIssue issueData, (err, result) ->
        console.log issueData
        console.log err
        resolve(result.title)

  matchIssue: (text) ->
    match = GitHubURLRegex.exec(text)
    GitHubURLRegex.lastIndex = 0 # yay global regexes!
    match

  extractURLs: (text) ->
    matchToURL = {}
    matches = text.match(GitHubURLRegex)
    for match in matches
      [wholeMatch, urlUser, urlRepo, urlNumber, issueUser, issueRepo, issueNumber] = @matchIssue(match)
      result = {}
      result.url = if urlUser?
        result.user = urlUser
        result.repo = urlRepo
        result.number = urlNumber
        "https://github.com/#{urlUser}/#{urlRepo}/issues/#{urlNumber}"
      else
        result.user = issueUser
        result.repo = issueRepo
        result.number = issueNumber
        "https://github.com/#{issueUser}/#{issueRepo}/issues/#{issueNumber}"
      matchToURL[wholeMatch] = result
    matchToURL
