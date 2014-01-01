yaml = require('js-yaml')
{dirname,basename,join} = require('path')
fs = require('fs')
async = require('async')
extend = require('node.extend')

DEFAULTS =
  source: 'app/locales'
  dest: 'public/locales'
  flatten: on
  locale:
    default: 'en'

getdirs = (path) ->
  names = fs.readdirSync(path)
  names.filter (filename) ->
    fs.statSync(join(path, filename)).isDirectory()

mkdirp = (dir) ->
  if fs.existsSync(dir)
    return
  parentDir = dirname(dir)
  if not fs.existsSync(parentDir)
    mkdirp parentDir
  fs.mkdirSync dir

safewrite = (path, data, callback) ->
  mkdirp dirname(path)
  fs.writeFile path, data, (err) ->
    callback(err)

# read a file only when existed
saferead = (path) ->
  if fs.existsSync(path)
    return fs.readFileSync(path, 'utf-8')
  return ''

# flatten nexted object
flatten = (obj, prev='') ->
  ret = {}
  for k,v of obj
    key = if prev is '' then k else "#{prev}.#{k}"
    if 'object' is typeof v
      extend true, ret, flatten(v, key)
    else
      ret[key] = v
  ret

# Merge b into a, and comment out keys not in b
compare_merge = (a, b) ->
  ret = {}
  for k,v of b
    # skip comment line in b
    if k[0] is '#'
      continue
    a_val = a[k] or a['#' + k]
    if 'object' is typeof v
      ret[k] = compare_merge(a_val ? {}, v)
    else
      ret[k] = a_val ? v
  for k,v of a
    # comment out unused keys
    if (k not of b) and (k[0] isnt '#')
      ret['#' + k] = v
  ret


# Skip comment when dumps json
json_skip_comment = (k, v) ->
  v if k[0] != '#'


module.exports = class Compiler
  brunchPlugin: true
  type: 'javascript'
  extension: 'yaml'
  pattern: /\.ya?ml$/

  constructor: (cfg) ->
    cfg = {} if cfg is null
    cfg = extend true, {}, DEFAULTS, cfg
    cfg.locale.all = getdirs(cfg.source) unless cfg.locale.all
    @cfg = cfg
    @default_dir = @sourceDir(cfg.locale.default)

  sourceDir: (locale) ->
    join(@cfg.source, locale)

  # sync domain yaml to other locales
  sync: (path, data, callback) ->
    data = yaml.safeLoad(data) or {}
    filename = basename(path)
    dosync = (item, callback) =>
      return callback(null, null) if item is @cfg.locale.default
      path = join(@sourceDir(item), filename)
      _data = yaml.safeLoad(saferead(path)) or {}
      _data = compare_merge(_data, data)
      safewrite(path, yaml.safeDump(_data), callback)
    async.each @cfg.locale.all, dosync, callback


  # copy src yaml file to dest, as json
  dump: (path, data, callback) ->
    dict = yaml.safeLoad(data) or {}
    if @cfg.flatten is on
      dict = flatten(dict)
    dest = path.replace @cfg.source, @cfg.dest
    dest = dest.replace @pattern, '.json'
    safewrite(dest, JSON.stringify(dict, json_skip_comment, 2), callback)
    
  isDefaultLocaleFile: (path) ->
    path.indexOf(@default_dir) == 0

  compile: (data, path, callback) ->
    ticker = 1
    tick = (err, result) ->
      return callback(err) if err
      ticker -= 1
      callback(null, null) if ticker <= 0
    if @isDefaultLocaleFile(path)
      ticker += 1
      @sync(path, data, tick)
    @dump(path, data, tick)
