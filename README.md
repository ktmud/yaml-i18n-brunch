# yaml-i18n-brunch

Generates translation dictionary as json files from yaml files.

## Installation

Install the plugin via npm with `npm install --save yaml-i18n-brunch`.

## Usage

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

Add translations into `app/locales` directory:

```
├── locales
│   ├── en
│   │   └── messages.yaml
│   └── zh-cn
│       └── messages.yaml

```

The plugin will try to compile all yaml files under `config.source`
into json, and put it into `config.dest`.


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

You can use nested object in yaml, if `config.flatten` is not `off`, the output will be flattened.

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

### config.locale.default

Each time you edit the default locale's yaml file. The distionary keys will be synchronize to other languages.

#### comment out unused translation

When you delete a key in default locale's yaml, the corresponding key is comment out in other languages,
but not deleted.  This is for keeping you from accidently losing translations when keys change.

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

The Chinese translation `locales/zh-cn/messages.yaml` would be:
```yaml
hello: 你好！
"#goodbye": 再见！
```

And the compiled json file will drop commented keys:

```json
{
  "hello": "你好！"
}
```

When use revert the deleted key, the old translation will be used.

I choose this approach because it would be difficult to compare yaml files line to line.

### config.locale.all

All locales available. If not set, will look up all directories under `app/locales`.


## Licence

The MIT License (MIT)

Copyright (c) 2013-2014 Jesse Yang (http://ktmud.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
