# Questions

## What is a Content Provider

- IPC : Interprocess Communication

- think of as database that is shared between processes and app

- eg: Contacts, MediaStore

## Differences between Dispatchers.Main / IO / Default

- Dispatcher (part of co-routine) which thread

### Dispatchers: .Main

- launches on main thread

###  Dispatcher: .IO

- has ~64 different threads

### Dispatcher: .Default

- Process large amounts of data

- As many threads as device has CPUs


#### Sample call
```kotlin
Coroutine(Dispatchers.IO).launch {

}
```

## What is 'Backpressure' in Kotlin Flows

- When the collector takes longer to process then flow produces

```kotlin
lifecycleScope.launch {
  flow {
     for(i in 1..100) {
       emit(i)
       delay(timeMillis = 300L)
     }.collect {
        delay(500L)  // takes longer to process then produces
        println(it)  // notice 'it' .. flow produces, collect consume
     }
  }
}
```

### Solutions:

- }.buffer().collect {

for large number of emits, may never finish in a reasonable manner

- }.conflate().collect {

only provides the latest emmission from the producer.

can have 'dropped' or lost emissions

- }.collectLatest {

simular to .collect{}, but will cancel the 'current' handler when
a new emission is received.

example: a 'search query' as the query changes, the latest 'collect'
uses the update query value (aka search bars as user types)

## Coroutine vs Thread

- Thread: Independent execution flow of a program
- Coroutine: Launched inside a thread {decided by *Dispatche*}
- Multiple Coroutines can run inside a thread
- Any suspending functions in a Coroutine only block the routine,
**not** the thread. ex: emit() or delay()
- A suspended coroutine resume right after suspension
- If a Coroutine executes blocking code (eg: Thread.sleep()),
***all***^ coroutines running in that thread are blocked

## *remember* vs *rememberSaveable*

```kotlin
setContent {
  InterviewQuestionsTheme {
    var counter by remember {
       mutableStateOf
    }
    var barney by rememberSaveable {
       mutableStateOf(0)
    }
  
  }

}
```

- *remember* : survives recomposition (aka changes in state)
- *rememberSaveable* : survives screen rotation, theme changes, changes
in system languages, if app/activity is backgrounded and resumed.
- *rememberSaveable* : can only work on **primitive** types
(aka serializable)

## Explain how Compose decides what to Recompose

- the ***by*** indicates the composer track/follow which Composable
{eg: Text() or Greeting()} should trigger a Recompose

## Difference between *val* and *const val*

- *const val*: The value must be known at compile time
- *val*: Can be defined with a function/dynamically but only once

## Explain Encapsulation

- The scope of what can be seen
- The 'black-box' approach, that is what other need to be know

## Difference between *Any* vs *Nothing* vs *Unit*

- *Any*: Same as **Dart** *Object*
- *Any*: Base class that has a toString() built in
- *Unit*: Plan object with no behavior at all

```kotlin
// Override toString()
public actual object Unit {
  override fun toString(): String = "kotlin.Unit"
}
```

- *Unit*: type returned if you call a **fun** that doesn't return
a value (example below - the ```fun Greeing()``` returns *Unit*

```kotlin
// inside a composable:
    val x = Greeing(name="Zack")
    

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}
```

- *Nothing*: Communicates to compiler there is no way to go past
the function call

- *Nothing*: when you call a 'Nothing' ```fun``` the complier will
warn that the following code is **unreachable**

```kotlin
fun doNothing(): Nothing {
   while(true){
     printlin("Doing nothing!")
   }
}

fun onlyKilsl() : Nothing {
   throw IllegalArguementException()
}
```

## *StateFlow* vs *SharedFlow* vs *Channel*

- *StateFlow<T>*: a **Hot Flow** that holds a value, the *state*.
eg: A counter you keep and listen for changes to the counter

- *SharedFlow<T>*: also a Hot Flow but the emissions have to consumed
or they are lost

```kotlin
val sharedFlow = MutableSharedFlow<Int>()

lifecycleScope.launch {
  sharedFlow.emit(0)
}
```

- *SharedFlow<T>*: Made for multiple consumers (eg external device
sends a piece of data, that data needs to consumed by all the
listeners to that *ShareFlow*)
- *ShareFlow<T>*: Like Dart ```StreamControler<>.broadcast()```

- *Channel<T>*: Meant for single subscriber
- *Channel<T>*: Has buffering
- *Channel<T>*: Like Dart ```StreamController<>``` can only have
1 listener





























