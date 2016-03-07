URLResolver = require '../lib/url-resolver'

expectToMatchURL = (match, owner, repo, number) ->
  expect(match[1]).toBe owner
  expect(match[2]).toBe repo
  expect(match[3]).toBe number

expectToMatchIssue = (match, owner, repo, number) ->
  expect(match[4]).toBe owner
  expect(match[5]).toBe repo
  expect(match[6]).toBe number

describe "GithubURLResolver", ->
  describe "the issue regular expression", ->
    it "matches URLs", ->
      match = URLResolver.matchIssue('http://github.com/atom/find/issues/255')
      expectToMatchURL(match, 'atom', 'find', '255')

      match = URLResolver.matchIssue('https://github.com/atom/find/issues/255')
      expectToMatchURL(match, 'atom', 'find', '255')

      match = URLResolver.matchIssue('github.com/atom/find/issues/255')
      expectToMatchURL(match, 'atom', 'find', '255')

      match = URLResolver.matchIssue('http://github.com/atom/find/pull/255')
      expectToMatchURL(match, 'atom', 'find', '255')

    it "matches issue syntax", ->
      match = URLResolver.matchIssue('atom/find#255')
      expectToMatchIssue(match, 'atom', 'find', '255')

  describe "extractURLs", ->
    it "extracts URLs", ->
      urls = URLResolver.extractURLs """
        atom/find#20
        http://github.com/atom/find/pull/30
        github.com/atom/find/issues/40
      """

      expect(urls['atom/find#20'].url).toEqual 'https://github.com/atom/find/issues/20'
      expect(urls['http://github.com/atom/find/pull/30'].url).toEqual 'https://github.com/atom/find/issues/30'
      expect(urls['github.com/atom/find/issues/40'].url).toEqual 'https://github.com/atom/find/issues/40'

    it "extracts URLs", ->
      urls = URLResolver.extractURLs """
        * ok then
        * http://github.com/atom/find/pull/30
        * atom/find#20
        * another
        * someuser/somerepo
      """

      expect(urls['http://github.com/atom/find/pull/30'].url).toEqual 'https://github.com/atom/find/issues/30'
      expect(urls['atom/find#20'].url).toEqual 'https://github.com/atom/find/issues/20'

  describe "resolveURLsInString()", ->
    describe "when fetchTitle succeeds", ->
      beforeEach ->
        spyOn(URLResolver, 'fetchTitle').andCallFake (issueData) ->
          num = issueData.url.match(/\d+$/)[0]
          Promise.resolve("Issue number #{num}")

      it "replaces URLs", ->
        urls = """
          atom/find#20
          http://github.com/atom/find/pull/30
          github.com/atom/find/issues/40
          someuser/somerepo
          word
          word#23
        """

        URLResolver.resolveURLsInString(urls).then (newString) ->
          expect(newString).toEqual """
            [Issue number 20](https://github.com/atom/find/issues/20)
            [Issue number 30](https://github.com/atom/find/issues/30)
            [Issue number 40](https://github.com/atom/find/issues/40)
            someuser/somerepo
            word
            word#23
          """

    describe "when fetchTitle fails", ->
      beforeEach ->
        spyOn(URLResolver, 'fetchTitle').andCallFake (issueData) ->
          Promise.resolve(null)

      it "replaces URLs", ->
        urls = """
          atom/find#20
          http://github.com/atom/find/pull/30
          github.com/atom/find/issues/40
          someuser/somerepo
          word
          word#23
        """

        URLResolver.resolveURLsInString(urls).then (newString) ->
          expect(newString).toEqual """
            atom/find#20
            http://github.com/atom/find/pull/30
            github.com/atom/find/issues/40
            someuser/somerepo
            word
            word#23
          """
