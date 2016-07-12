# PathPuz
Play path-based logic puzzles (like Monorail, Alcazar, Slitherlink) in a web browser.

## Usage
Currently, Monorail is the only puzzle type implemented.

### Monorail

The goal is to connect all the dots with a single closed loop that does not cross itself. Some puzzles will start
with some dots already connected.

Click (or tap) between two dots to connect them with a line. Click again to mark a line absent, i.e. to indicate
that two dots cannot be connected directly. Click a third time to go back to being undetermined.

Click on a dot to auto-complete it: if there is only one way for the loop to go through the dot, the appropriate
lines will be filled in; if there are already lines going into and out of the dot, then the other lines will be
marked absent.

The Hint button will find a dot to auto-complete, if there are any, and complete it.

The Auto-hint option will auto-complete all dots whenever possible.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pathpuz'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install pathpuz
```

## Contributing
The front end is implemented using [Opal](http://opalrb.org/), a compiler from Ruby to Javascript. Source code is
in `app/assets/javascripts`. Unit tests are in `test/javascripts`. Feature tests are in `test/features`. To run the
tests, just run `bundle` and then `rake`.

## License
The gem is available [as free software](https://github.com/dougo/pathpuz) under the terms of the [AGPL](http://www.gnu.org/licenses/agpl.html).
