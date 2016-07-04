# Description:
#   Search the Reader and provide links to the first 3 articles
#
# Dependencies:
#   none
#
# Configuration:
#   HUBOT_READER_EMAIL
#   HUBOT_READER_TOKEN
#
# Commands:
#   learnbot reader me <query> - Search for the query
#
# Author:
#   wrdevos

module.exports = (robot) ->
  robot.respond /reader me (.*)/i, (msg) ->
    searchQuery = msg.match[1]

    articleSearch msg, searchQuery

articleSearch = (msg, searchQuery) ->
  data = ""
  msg.http("https://read.codaisseur.com/search.json")
    .query
      search: encodeURIComponent(searchQuery)
      user_email: process.env.HUBOT_READER_EMAIL
      user_token: process.env.HUBOT_READER_TOKEN
    .get( (err, req)->
      req.addListener "response", (res)->
        output = res

        output.on 'data', (d)->
          data += d.toString('utf-8')

        output.on 'end', ()->
          parsedData = JSON.parse(data)

          if parsedData.error
            msg.send "Error searching Reader: #{parsedData.error}"
            return

          if parsedData.length > 0
            qs = for article in parsedData[0..3]
              "https://read.codaisseur.com/topics/#{article.topics[0].slug}/articles/#{article.slug} - #{article.title}"
            if parsedData.total-5 > 0
              qs.push "#{parsedData.total-3} more..."
            for ans in qs
              msg.send ans
          else
            msg.reply "No articles found matching that search."
    )()
