# VeeranTheHero.com site builder

## Rake commands
`rake -P` - lists all tasks with their dependencies.
`rake taskname --trace --rules`

Or just add this line at the top of Rakefile:

```
Rake.application.options.trace_rules = true
```
ruby -run -e httpd . -p 8000
