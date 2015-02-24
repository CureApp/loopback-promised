colors =
  'red'    : '31'
  'green'  : '32'
  'yellow' : '33'
  'blue'   : '34'
  'purple' : '35'
  'cyan'   : '36'

module.exports = (str, color) ->
    return str if not color or not colors[color]
    colorNum = colors[color]

    return "\u001b[#{colorNum}m#{str}\u001b[39m"

