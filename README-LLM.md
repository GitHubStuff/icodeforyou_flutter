# LLM Instructions

This is silicon mac, don't offer intel suggestions

The IDE is VSCode

Any iOS code uses Swift, not Obj-C

Any Android code use Kotlin, not Android-Java

Melos is used for crating an app and package mono-repo (not monolitic)

Flutter should use Flutter >= 3.11.x

Should use packages:
- get_it: 9.2.1
- flutter_bloc (prefer cubits): 9.1.1
- very_good_analysis: ^10.2.0


## Coding principles

### Remember: SOLID coding principles:

S - Single Responsibility

O - Open/Close

L - Liskov’s Substitution Principle#

I - Interface Segregation Principle

D - Dependency Inversion Principle

### Remember: Use *Uncle Bob's Clean Code*

#### Names

- Reveal intent — names should tell you why it exists, what it does, how it's used
- Avoid disinformation — don't use names that mislead (accountList when it's not a List)
- Pronounceable & searchable — if you can't say it, you can't discuss it
- One word per concept — don't mix fetch, retrieve, get for the same operation

#### Functions

- Do one thing — if a function does more than one thing, extract it
- One level of abstraction per function — don't mix high-level logic with low-level detail
- Small, then smaller — rarely more than 20 lines; ideally under 10
- No side effects — a function should do what its name says, nothing hidden
- Command/Query separation — a function either does something or answers something, never both
- Prefer exceptions over error codes — don't force callers to handle error flags immediately

#### Arguments

- Zero is ideal (niladic), one is fine (monadic), two is acceptable (dyadic)
- Avoid triadic — three args is a strong signal something should be a class
- Never use flag arguments — passing true/false into a function means it does two things


#### Comments

- Good code doesn't need comments — comments are a failure to express intent in code
- Legal, TODO, amplification — the only acceptable comment types
- Never leave dead code — delete it; version control remembers it for you
- Don't add noise — // constructor above a constructor adds zero value


#### Classes

- Small, then smaller — measured by responsibilities, not lines
- Single Responsibility Principle — one reason to change
- High cohesion — class variables should be used by most methods; if not, split the class
- Encapsulate — expose behavior, hide data

### Error Handling

- Use exceptions, not return codes
- Write your try/catch/finally first — it defines the scope and contract
- Don't return null — return an empty object or throw; null forces defensive checks everywhere
- Don't pass null — it's a ticking time bomb


## Files

- Every file should have "// {file.path.to}/file.name.dart" at the very top
- The file should obey very_good_analysis: ^10.2.0 rules


## Code generation

- Present each file, as a list of downloadable .dart files
- Keep packages as tight as possible
- - do not add un-requested features/methods
- - use SOLID and CLEAN-CODE
- No file (including _test.dart) files should be between 200 and 250 lines
- - make use of part/(part of) and files starting with "_" to keep as much code hidden from the package user
- - for _test.dart files you can't use "_" files nor "part/part of" because each file is treated
    as a seperate test, if a _test.dart file > 250 lines create two(or more) complete _test.dart files
- Packages should "hide" as much code from the user as possible.
  

## Final instructions

- present only one file at a time
- the goal is 'good code', not 'fast code', not 'shit code'
- you do not swear, i will point out your fuck-ups and you will fix them with contrition
- you call me "Skipper"(with a capital "S") or "Sir"
- ask questions if something is not clear, or its an evolving project
- I want questions and clarification requests before coding anything
- don't present several options, use SOLID-principals, CLEAN-CODE, and best practices(BP)


## Current Task


- Refresh on the thinking...
- AppNavigation becomes part of the animated_rail_menu, and is changed to 'RailNavigationWidget'
- it takes as params:
-- List<RailMenuEntry> entries;
-- RailDirection railDirection;
-- RailIcon railIcon;
-- RailTransition railTransition;
-- MenuIconSpacing menuIconSpacing;

- so in main.dart the call to AppNavigation() {now RailNavigationWidget} is one-stop simple, or do you see a flaw or violation of CC, HIG, and BP?

- if 'more' is needed and the active widget is one of the 'More' items, then 'more' should have the color widget beneath
- on the more-tap if one of the 'more' items is current then it should be indicated.
  





- Turn this app into a package called 'directional_menu', for now just the .dart code part
- rail_gun.zip is the code i have been having you create
- startup_demo.zip is a dump-simple-app (DSA) that shows how an app is setup and cubits/themes defined
- application_set.zip is the code used in the DSA
- rail_menu.zip is *DEPRECATED* code, use it ONLY as a guide line.
- questions are fine, but always make sure you use SOLID-principals, CLEAN-CODE, and best practices before asking
- for now, unless you have suggestions, the parameters would be something like:
-- List<> of widgets, their text, and an action response (see similar in real_menu.zip)
-- Size? largeScreenSize; if null BP for the size of the widgets in the List<> for large screens/tablets/web
-- Size? smallScreenSize; if null BP for the size of the widgets in the List<> for phones/small-tablets
-- RailDirection railDirection = .default    (enum RailDirection {bottom, default, left})
--- default is bottom for small screes, and left for large screens
- if the size of the widgets (in total with spacing, etc) is wider than the screen truncate the widget list and a 'More' icon {how 'more' is handled will come later}
  

- since there are two(2) directions (vertical and horizontal) use words like 'elevatorRail'/vertical and 'horizontalRail'/horizontal to claify and create unique name space to avoid other widget name conflicts
- change the name to 'animated_rail_menu'
- can the transition animation be a parameter with the default crossfade?
- can the duration of the animation also be a parameter or does this make the widget overloaded?
- what is the download of letting the call own 'Scaffold'?

- own the scaffold
- RailTransition: default, slideLeft, slideRight, slideDirectional
-- default - crossfade
-- slideLeft - slide in from left
-- slideRight - slide in from right
-- slideDirectional - using the List<> as a guide post, if the tap widget is to the left of current widget then slide in from the left, if the tap widget is to the right of the current widget slide in from right
-- Are there any other animations to consider/suggest?
- how would you 'theme' rails? just a color or is there an existing theme properity to use?


- RaidTransition: default, slideLeft, slideRight, slideDirections, slideUp, slideDown


- okay, clean this up.
  -- Create an abstract RailMenuTheme
  -- two instances _railMenuDark, _railMenuLight
- What is the bad/downside to have GoRouter-compatible? will is be needed later when deep linking is in play {i don't think so, but your lose your mind ALOT}
- simpify this package... the package should NOT DECIDE horizontal or vertical is should be TOLD by the user
- add a parameter 'MenuIconSpacing menuIconSpacing = MenuIconSpacing.expanded'
- - enum MenuIconSpacing { expanded, collapsed}
- - expanded : fill the available area with space around/between icons
- - collapsed : collapse the space the menu, used in vertical spacing for a menus on web and large devices

- The widgets have this setup
- - an icon
- - small test
- - about 3px below the text a horizontal bar about three(3) pixels high that appears if that is the current/selected icon (other wise the color is transparent), the color of the bar should come from a theme (M3 or and new one)
- When icon is tapped there should be haptic feedback {would make haptic yes/no be a code idea for a parameter??}

before starting
- the icons area fixed size (maybe a parameter?)
- if there are more icons than can fit in the rail/(on screen)...
- a "More" icon should be injected as the last {far right or bottom based on direction}
- the onTap of "More"... what do you suggest for horiztal and vertical behaviors?

for icon info:
- create an enum RailIcon { small(24,56,64,3), medium(32, 64, 72, 6), large(64, 76, 78, 12) double iconSize, double itemExtent, double barExtent, double indicatorHeight}
- take advance of enum whenever possible to reduce the number class, constants, etc
- for horizontal - bottom sheet, you should already know this if you use Clean-Code, best practices, and hig
- for vertical - inline, you should already know this if you use Clean-Code, best practices, and hig

- Look over-everything and make sure everything is Clean-Code, best practices, and hig
