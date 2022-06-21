# forem-vala

Unofficial [Forem](https://forem.com) API client library for Vala. Still a work in progress.

## Compilation

I recommend including `forem-vala` as a git submodule and adding `forem-vala/src/Forem.vala` to your sources list. This will avoid packaging conflicts and remote build system issues until I learn a better way to suggest this.

### Requirements

```
meson
ninja-build
valac
```

### Building

```bash
meson build
cd build
meson configure -Denable_examples=true
ninja
./examples/hello-forem
```

Examples require update to username and [API key](https://developers.forem.com/api#section/Authentication), don't check this in

```
string user = "username";
string key = "api-key";
```

# Quick Start

## New Login

```vala
string user = "user";
string key = "api-key";

Forem.Client client = new Forem.Client ("https://dev.to/");
if (client.authenticate (
        user,
        key))
{
    print ("Successfully logged in");
} else {
    print ("Could not login");
}
```

## Check Logged in User

```vala
string my_username;
if (client.get_authenticated_user (out my_username)) {
    print ("Logged in as: %s\n", my_username);
}
```

## Publish a Post

```vala
string url;
string id;
if (client.publish_post (
    out url,
    out id,
    "# Hello Forem!

Hello from [ThiefMD](https://thiefmd.com)!",
    "Hello Forem!"))
{
    print ("Made post: %s\n", url);
}
```
