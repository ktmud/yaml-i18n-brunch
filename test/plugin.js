var fs = require('fs');
var should = require('should');

function unlink(path) {
  //path = process.cwd() + path;
  //console.log(path);
  if (fs.existsSync(path)) {
    fs.unlinkSync(path)
  }
}
function read(path) {
  return fs.readFileSync(path, 'utf-8');
}

describe('Plugin', function() {
  var plugin;

  beforeEach(function() {
    plugin = new Plugin({
      source: __dirname + '/data/source',
      dest: __dirname + '/tmp',
      locale: {
        default: 'zh-cn'
      }
    });
  });

  function yamlPath(locale, domain) {
    return __dirname + '/data/source/' + locale + '/' + domain + '.yaml';
  }
  function jsonPath(locale, domain) {
    return __dirname + '/tmp/' + locale + '/' + domain + '.json';
  }

  var source_yaml, target_yaml, source_json, target_json;

  function getPaths(domain) {
    source_yaml = yamlPath('zh-cn', domain);
    target_yaml = yamlPath('en', domain);
    source_json = jsonPath('zh-cn', domain);
    target_json = jsonPath('en', domain);
  }

  function doCompile(file, done) {
    var data = read(file);
    plugin.compile(data, file, done);
  }

  function clean() {
    target_yaml && unlink(target_yaml);
    source_json && unlink(source_json);
    target_json && unlink(target_json);
  }

  describe('api', function() {

    it('should parse config options', function() {
      plugin.should.have.property('cfg');
      plugin.cfg.locale.default.should.equal('zh-cn');
      plugin.cfg.flatten.should.equal(true);
    });

    it('should be aware of default path', function() {
      plugin.isDefaultLocaleFile(yamlPath('zh-cn', 'messages')).should.equal(true);
    });

    it('should callback null when compile', function(done) {
      plugin.compile('', yamlPath('zh-cn', 'messages'), function(err, res) {
        should.not.exist(err);
        should.not.exist(res);
        done();
      });
    });

  });

  describe('compile default', function(e) {

    beforeEach(function(done) {
      getPaths('messages');
      unlink(target_yaml);
      doCompile(source_yaml, done);
    });
    afterEach(clean);

    it('should sync', function() {
      read(source_yaml).should.equal(read(target_yaml));
    });

    it('should generate json', function() {
      require(source_json).test.should.equal('test1');
    });

  });


  describe('compile tomerge', function(e) {

    var merged;

    beforeEach(function(done) {
      getPaths('tomerge');
      // override en/tomerge.json to original
      fs.writeFileSync(yamlPath('en', 'tomerge'), read(yamlPath('en', '_tomerge')));
      doCompile(source_yaml, function() {
        merged = read(target_yaml);
        done();
      });
    });
    afterEach(clean);

    it('should merge', function() {
      merged.should.include("only_source: source");
    });

    it('should leave translation intact', function() {
      merged.should.include("both: target");
    });

    it('should comment unused', function() {
      merged.should.include('"#only_target": target');
    });

    it('json should not have commented key', function(done) {
      doCompile(target_yaml, function(err, res) {
        should.not.exist(require(target_json).only_target);
        done();
      });
    });

  });

  describe('compile nested', function(e) {
    beforeEach(function(done) {
      getPaths('nested');
      doCompile(source_yaml, done);
    });
    afterEach(clean);

    it('should sync yaml', function() {
      read(source_yaml).should.equal(read(target_yaml));
    });

    it('should flatten json', function() {
      require(source_json)['test.nest1'].should.equal('hello');
    });

  });

});
