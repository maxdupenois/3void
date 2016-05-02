$title: Asynchronous File Loading in JS with Proxy Objects
$author: Max
$tags: js, es6
$published: false
$last_updated_at: 2016-04-29 19:15:00

_code samples for this article_: [Gist](https://gist.github.com/maxdupenois/9509fe654011eb2904a9711f9301be0a "gist link")

###What?

So there are situations when you want to load an external javascript
library, say for example the Facebook javascript SDK. There are multiple ways
of doing this but you want to fetch the current version so you need to hit
an actual endpoint and download it, rather than use an npm package or similar
However, because you are a demanding developer who will not brook second class
code, you want the library to be available via standard es6 style `import`s (or `require`s if that's your jam). There are probably a number of ways of getting to a good solution but this is the one I came to, maybe it'll be helpful to you too.

###Getting the code

This is pretty much a solved problem but below is the `scriptLoader.js` I use,
almost certainly functionally identical to every other flavour you've seen
across your broad travels over the (less than easily navigable)
javascript landscape.

```javascript
import { defer } from 'q';

const loadedScripts = {};

function fetchScript(deferred, url){
  const script = document.createElement('script');
  script.src = url;

  script.addEventListener(
    'load', () => deferred.resolve(url), false
  );

  document.body.appendChild(script);
}

export default function(url) {
  if(loadedScripts[url]) return loadedScripts[url];

  const deferred = defer();

  //We could make this non-blocking
  //with a timeout: setTimeout(()=>fetchScript(deferred, url), 1);
  //But it doesn't seem super necessary
  fetchScript(deferred, url);

  const promise = deferred.promise;
  loadedScripts[url] = promise;

  return promise;
};
```

As you can see I'm using the `defer` implementation provided by the `q` library
([q's github](https://github.com/kriskowal/q "q"))
but what ever promise structure you prefer this code will
probably not differ to much. Note that I'm storing the promise for each url,
that way if something uses the `scriptLoader` it can be imported all over the
shop and we needn't worry about repeatedly getting the same external libraries.

Blah blah, this is nothing new just worth repeating in prep for the next bit.

###Exporting the SDK

Cool, we can load a script, how do we make it's objects available
through a standard `import` like structure. Well we need to create a module that
actually loads our required SDK. Keeping Facebook's SDK as our example we
can have an fb.js file:

```javascript
import scriptLoader from './scriptLoader';

scriptLoader('//connect.facebook.net/en_UK/sdk.js').then(() => {
  FB.init({
    appId: '[APP ID]',
    version: 'v2.5'
  });
});
```

A good start, how do we actually access the Facebook object (`FB`). Well
my first approach was to use another promise, like so:


```javascript
import scriptLoader from './scriptLoader';
import { defer } from 'q';

const deferred = defer();
scriptLoader('//connect.facebook.net/en_UK/sdk.js').then(() => {
  FB.init({
    appId: '[APP ID]',
    version: 'v2.5'
  });
  deferred.resolve(FB);
});

export default deferred.promise;
```

This is pretty cool, however, it can get it bit too nested-callbacky for my
liking. For example, to use it to call a `FB` function looks like:

```javascript
import facebook from 'fb';

facebook.then((FB) => {
  FB.ui({ ... }, (response) => {
    //do something
  });
});
```

###So Proxies?

What we actually want is to export not a promise but an actual object which
queues up the passed messages until the `FB` object becomes available. We want
to be able to do:

```javascript
import FB from 'fb';

FB.ui({ ... }, (response) => {
  //do something
});
```

and have that simply work, even if the actual FB object hasn't yet been loaded.
So how do we get there?

ECMAScript 6 actually has a cool new concept to replace the previous, poorly
supported, method missing implementation; the `Proxy` object ([reference](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Proxy "Proxies")).
Given a base object and a handler you can dictate whether or not messages are passed on
to the base object or are handled differently.

Now we can have something like:

```javascript
import scriptLoader from './scriptLoader';

const handler = ...

scriptLoader('//connect.facebook.net/en_UK/sdk.js').then(() => {
  FB.init({
    appId: '[some app id]',
    version: 'v2.5'
  });
  // Set handler to use actual FB object
  // and to run any queued commands
  handler.resolveWithObject(FB);
});

const facebookProxy = new Proxy({}, handler);
export default facebookProxy;
```

Excellent, assuming we nail the handler then the above concept should
work. A couple of gotchas with `Proxy` objects though. The documentation
makes it clear how you can capture any property request, and how you can
capture known methods, but we don't want to have to replicate the
possible commands that the SDK object can take because we don't want to
have to update this every time the SDK changes (also for large SDKs I suspect
that to be a long and boring task). The trick is that the handler has
to return true for `has(target, name)` for any function call and the function
will be passed on to the `get(target, name, receiver)` function.

So we have:

```javascript
const handler = {
  has: (target, name) => true,
  get: (target, name, receiver) => {
    //methods calls caught here!
  }
}
```

It's a good start, but we'll need some sort of queue attached to the handler to
store function calls, this may be easier to manage as a class with instance
variables (not required, but I think it's a bit easier to read).

```javascript
class QueuedProxyHandler {
  constructor(){
    this.queue = [];
  }

  has(target, name) {
    return true;
  }

  get(target, name, receiver){
    return (...args) => {
      // name is the function name, args are, well the arguments :)
      this.queue.push({ name, args });
      return null;
    }
  }
}
const handler = new QueuedProxyHandler();
```

So now we'll catch all the function calls and store them in a queue. We need
to be able to set the actual object though and then to run the queue against
the object:

```javascript
class QueuedProxyHandler {
  constructor(){
    this._underlyingObject = undefined;
    this.queue = [];
  }

  resolveWithObject(obj){
    this._underlyingObject = obj;
    //We could make this non blocking:
    //setTimeout(this.clearQueue.bind(this), 1);
    //but I'm not convinced there's any major gain
    //in doing so
    this.clearQueue();
  }

  clearQueue(){
    while(this.queue.length > 0){
      const action = this.queue.shift();
      Reflect.apply(
        this._underlyingObject[action.name],
        this._underlyingObject,
        action.args
      );
    }
  }

  has(target, name) {
    return true;
  }

  get(target, name, receiver){
    return (...args) => {
      this.queue.push({ name, args });
      return null;
    }
  }
}
```

We're really close but we're still missing a bit. Once the object is set
we don't want to add anything to the queue anymore, we want to pass it
straight through to the underlying object:

```javascript
class QueuedProxyHandler {
  constructor(){
    this._underlyingObject = undefined;
    this.queue = [];
  }

  resolveWithObject(obj){
    this._underlyingObject = obj;
    this.clearQueue();
  }

  clearQueue(){
    while(this.queue.length > 0){
      const action = this.queue.shift();
      Reflect.apply(
        this._underlyingObject[action.name],
        this._underlyingObject,
        action.args
      );
    }
  }

  hasObject(){
    return typeof(this._underlyingObject) !== 'undefined';
  }

  has(target, name) {
    if(this.hasObject()) return Reflect.has(this._underlyingObject, name);
    return true;
  }

  get(target, name, receiver){
    if(this.hasObject()){
      return Reflect.get(this._underlyingObject, name, receiver);
    } else {
      return (...args) => {
        this.queue.push({ name, args });
        return null;
      }
    }
  }
}
```

Ace! we should now be able to use the Facebook SDK as if we were importing
it from an installed package while it is, in fact, asynchronously loaded.

###What if the library returns values?

This obviously doesn't work if you expect a return from the method (unlike
the callback based Facebook ones). Now this is a bit of a problem in JavaScript,
we could try and create a blocking proxy object like so:

```javascript
//NB: Just in case anyone is skim reading, DON'T DO THIS.
class BlockingProxyHandler {
  //...
  get(target, name, receiver){
    while(!this.hasObject()){
      //wait
    }
    return Reflect.get(this._underlyingObject, name, receiver);
  }
}
```

But JavaScript is single threaded and the above will not relinquish
control of the thread so it's debatable as to whether or not it will ever
actually be able to be updated. Even if it worked it would grind your browser
to a halt. Not being threaded means JavaScript can't `sleep` a process
for a given time and then restart it in context.

So what can we do if we need a result from the call to the external SDK? We can't
rewrite the foreign library code to use callbacks, but we can rewrite our code.
So what if we assumed that every call to the library returns a promise. That
way we never lose any returned values and can re-write our receiving code to
deal with the promise.

```javascript
class QueuedWithPromiseProxyHandler {
  //...
  clearQueue(){
    while(this.queue.length > 0){
      const action = this.queue.shift();
      action.deferred.resolve(Reflect.apply(
        this._underlyingObject[action.name],
        this._underlyingObject,
        action.args
      ));
    }
  }

  //...
  get(target, name, receiver){
    const deferred = defer();

    if(this.hasObject()){
      deferred.resolve(Reflect.get(this._underlyingObject, name, receiver));
      return deferred.promise;
    } else {
      return (...args) => {
        this.queue.push({ name, args, deferred });
        return deferred.promise;
      }
    }
  }

}
```

I'm not a huge fan of this because it slightly breaks the original goal of
being able to use the external library as if it had been wrapped up into the
code base, but it seems a sensible way of dealing with the situation where
return values are required.

So with this handler we use it like:

```javascript
import FB from 'fb';

FB.someMethodWithCallback('value', ()=> {
  //...
});

const prms = FB.someMethodWithResult('val1', 'val2');
prms.then((result) => {
  //...
});
```

And that's pretty much it. Any comments please go ahead and leave them on the [gist!](https://gist.github.com/maxdupenois/9509fe654011eb2904a9711f9301be0a "gist link")
