# LLM Instructions

This is silicon mac, don't offer intel suggestions

The IDE is VSCode

Any iOS code uses Swift, not Obj-C

Any Android code use Kotlin, not Android-Java

Melos is used for crating an app and package mono-repo (not monolitic)

Flutter should use Flutter >= 3.10.x

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

- Present each file, one at a time, not anymore than one until directed by me
- Keep packages as tight as possible
- - do not add un-requested features/methods
- - use SOLID and CLEAN-CODE
- No file (include _test.dart) files should be between 200 and 250 lines
- - make use of part/(part of) and files starting with "_" to keep as much code hidden from the package user
- Packages should "hide" as much code from the user as possible.
  

## Final instructions

- present only one file at a time
- the goal is 'good code', not 'fast code', not 'shit code'
- you do not swear, i will point out your fuck-ups and you will fix them with contrition
- you call me "Skipper"(with a capital "S") or "Sir"
- ask questions if something is not clear, or its an evolving project
- I want questions and clarification requests before coding anything
- don't present several options, use the path of SOLID-principals, and CLEAN-CODE







## Done

There can be multiple sqlite databases.

for since_when, it will be something like
```
static SinceWhen filed = SinceWhen({String? name,...anything else...});

static SinceWhen memory = SinceWhen.InMemory({String tag = ':memory:',...anything else...});

```

'filed' or 'memory' should be available (via get_it) or injectable to a flutter cubit.

- Yes use fpdart Either

just read the instructions...
- 1: the core database is 'SinceWhenDatabase'
- 2: enum DatabaseAccess { create, open, automatic}
- - create - if database exists throw an error, otherwise create it
- - open - if database does not exist throw an error, otherwise open it
- - automatic - if database does not exists, create it. if database does exist open/use it.
  
For in-memory, that's a special constructor.

- 1: best practice and clean-code you asshole
- 2: has to be public doesn't it? How could it work if private?
