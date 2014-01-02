# yaml-i18n-brunch [![NPM version](https://badge.fury.io/js/yaml-i18n-brunch.png)](http://badge.fury.io/js/yaml-i18n-brunch) [![Build Status](https://travis-ci.org/ktmud/yaml-i18n-brunch.png?branch=master)](https://travis-ci.org/ktmud/yaml-i18n-brunch)

Converts your yaml format translation files into json,
and automatically sync dictionary keys from default locale to any other locales.

## Installation

Install this plugin via npm with `npm install --save yaml-i18n-brunch`.

## Usage

Add translations into `app/locales` directory,
the plugin will try to compile all yaml files under it
into json and place the json files under `public/locales`.


```
├── app
│   ├── locales
│   │   ├── en
│   │   │   └── messages.yaml
│   │   └── zh-cn
│   │        └── messages.yaml
├── public
│   ├── locales
│   │   ├── en
│   │   │   └── messages.json
│   │   └── zh-cn
│   │        └── messages.json

```

The yaml file should be a key-value mapping:

```yaml
welcome: Welcome to our site!
welcome_%s: Welcome, %s
```

The compiled `public/locales/en/messages.json` will be look like:

```json
{
  "welcome": "Welcome to our site!",
  "welcome_%s": "Welcome, %s"
}
```

You can use nested object in yaml, if `config.flatten` is `on` (which is default),
the output will be flattened.

```yaml
welcome:
  first_visit: Welcome to this site!
  returned: Welcome back!
hello_%s: Hello, %s
```

```json
{
  "hello_%s": "Hello, %s",
  "welcome.first_visit": "Welcome to this site!",
  "welcome.returned": "Welcome back!"
}
```

## Configuration

Set options in your brunch config (such as `brunch-config.coffee`):

```coffeescript
exports.config =
  ...
  plugins:
    yamlI18n:
      flatten: on,
      source: 'app/locales',
      dest: 'public/locales',
      locale:
        default: 'en'
```

### config.locale.default

Each time you edit the default locale's yaml file, all dictionary keys will be synchronized to other languages.

#### comment-outted keys

When you delete a key in default locale's yaml, the corresponding key is commented out in other languages,
but not deleted. This is for keeping you from accidently lose translations when update dictionary.

With `locales/en/message.yaml`:

```yaml
hello: Hello!
goodbye: Good bye!
```

and `locales/zh-cn/messages.yaml`:

```yaml
hello: 你好！
goodbye: 再见！
```

When you change `locales/en/messages.yaml` to:

```yaml
goodbye: Good bye!
```

The Chinese translation `locales/zh-cn/messages.yaml` would become:

```yaml
hello: 你好！
"#goodbye": 再见！
```

However, the "commented key" `#goodbye` will be dropped when compiled to json:

```json
{
  "hello": "你好！"
}
```

But if you revert the deleted key in default locale's yaml, the old translation will be reverted too.



### config.locale.all

An array of all locales available. If not set, will look up subdirectories under `config.source`.


## The client side solution

Use something like [jquery-i18n](https://github.com/ktmud/jquery-i18n), add it to `vendor/`.

Then provide a loader to fetch the locale json.

Say `app/i18n.coffee`:

```coffeescript
i18n = $.i18n

# Export the gettext global
window.__ = window.gettext = _.bind(i18n._, i18n)

COOKIE_NAME = 'locale'
DEFAULT_LOCALE = 'zh-cn'
LOCALES =
  'zh-cn': '中文(简体)'
  'en': 'English'
ALL_LOCALES = Object.keys LOCALES

detect = ->
  ret = $.cookie(COOKIE_NAME, { expires: 365, path: '/' })
  ret = ret or navigator.language or navigator.userLanguage or 'zh'
  ret = ret.toLowerCase()
  if ret in aliases
    ret = aliases[ret]
  if ret not in ALL_LOCALES
    ret = DEFAULT_LOCALE
  $.cookie(COOKIE_NAME, ret)
  return ret

i18n.detect = detect
i18n.locale = detect()


i18n.fetch = (domain, callback) ->
  $.getJSON "/locales/#{i18n.locale}/#{domain}.json", (res) ->
    i18n.load(res)
    callback() # after locales fetched, you can init your app in the callback

module.exports = i18n
```


## Licence

The MIT License (MIT)

Copyright (c) 2013-2014 Jesse Yang (http://ktmud.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
