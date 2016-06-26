# Template Setup

## 1. Content directory
```
$HOME/.codestrap/content
```

The content directory contains all file and project templates.
 
### Individual text file templates

Individual text templates as files ending in .erb (EG script.erb). These are Embedded Ruby files. Objects in these files are generated from files contained in the *objects/* directory.

  * Each file ending in .erb has a one to one relationship with a generated command.
  * Generated commands for individual text files begin with *stub* and end with the same name as the file under *content* minus the .erb postfix.

### Project templates

Sub directories form project templates (EG content/puppetmodule).

  * Each sub-directory has a one to one relationship with a generated command.
  * Generated commands for projects begin with *strap* and end with the same name as the sub-directory.

#### ERB templates and project context

ERB Files in a project template do not end in ".erb". Instead the files have a *modeline* entry "strap:erb" or "stub:erb" (within the first 10 lines), to indicate an ERB template.
```erb
#!/bin/sh
# strap:erb
# Author: <%= author.name %>
# Email: <%= author.email %>
```

Note: Modelines are removed from the generated boilerplate

#### Directory text interpolation

Directory names can contain variables/objects which are interpolated with the idiom ":strap:object.text:" or ":stub:object.text:"
```
content/PROJECT/:strap:project.name:/myfile.txt
content/PROJECT/:stub:project.name:/myfile.txt
```

## 2. Generated commands directory
```
$HOME/.codestrap/bin
```

Contains generated commands (symlinks). Generated commands have a one to one relationship with a content directory file/sub-directory.

  * Generated commands corresponding to text file templates begin with *stub* followed by *textfile* (minus the .erb) in the content directory.
  * Generated commands corresponding to project templates begin with *strap* followed by *dir* in the content directory.

## 3. Variable/Object definition files directory
```
$HOME/.codestrap/objects
```

Contains *.json, *.yaml or executable files which output JSON. Objects are available in YAML format.

### YAML Objects

A file named *"company.yaml"* with content
```yaml
name: ACME Corp.
email: email@address.com
url: "http://www.company.com"
```

Creates an object "company" with interfaces "company.name", "company.email" and "company.url". Each interface corresponds to the relevant *"company.yaml"* file entry.

The "company" object is then available to all template files.

*Example ERB*
```erb
#!/bin/sh

mail -s "Order product" <%= company.email %> <<EOF
Hello <%= company.name %>,

I just ordered more product from <%= company.url %>.
EOF
```

### JSON Objects

A file named *"socialmedia.json"* with content
```json
{
  "twitter": "supercoder",
  "facebook": "http://www.facebook.com/supercoder"
}
```

Creates an object "socialmedia" with interfaces "socialmedia.twitter", "socialmedia.facebook" interfaces containg the relevant values from *socialmedia.json*

*Example use in a ERB file*
```erb
#!/bin/sh

echo "Posting to <%= socialmedia.facebook %> and sending a tweet to <%= socialmedia.twitter %>
```

### Executable file Objects

Executable file objects are similar to JSON Objects except the JSON string is parsed directly from script standard output (STDOUT).

A file named *"system.sh"* with content
```sh
#!/bin/sh
cat <<EOF
{
  "hostname": "$(hostname)",
  "uname": "$(uname -a)",
  "uptime": "$(uptime)"
}
EOF
```

Creates an object "system" (All postfixes are stripped out EG .sh .py .rb), with interfaces "system.hostname", "system.uname" and "system.uptime" containing values of the same unix command.

*Example use in a ERB file*
```erb
#!/bin/sh

echo "The Uptime of host <%= system.hostname %> is <%= system.uptime %>."
echo "The kernel version is <%= system.uname %>
```

### Default Objects

Codestrap also creates objects internally for use in templates.

*project*
```erb
<%= project.module %> - Name of the strap$MODULE or stub$MODULE used.
<%= project.name %> - Name of directory or file output.
```

*datetime*
This is the DateTime object used in Ruby created using "DateTime.now()". You can use any methods available to this object in your code but to save time here are some useful ones.

*Example use in a ERB file*
```erb
<%= datetime.strftime('%c') %> - Sample "Wed Jun 29 23:20:49 2016"        - Date and Time (%a %b %e %T %Y)
<%= datetime.strftime('%D') %> - Sample "06/29/16"                        - Date (%m/%d/%y)
<%= datetime.strftime('%F') %> - Sample "2016-06-29"                      - The ISO 8601 date format (%Y-%m-%d)
<%= datetime.strftime('%R') %> - Sample "23:20"                           - 24-hour time (%H:%M)
<%= datetime.strftime('%T') %> - Sample "23:20:49"                        - 24-hour time (%H:%M:%S)
<%= datetime.strftime('%+') %> - Sample "Wed Jun 29 23:20:49 +10:00 2016" - date(1) (%a %b %e %H:%M:%S %Z %Y)
```
