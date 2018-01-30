# Operations and Operation Queue Example

This project purpose is to illustrate the power of the Operations and Operation Queues. How can use them in iOS project. What we can achieve. Operations and operation queue makes your project maintainable, scalable, testable, organized.
   
The big story of the current project you can read HERE<br />
Look at the short story here

# Operation in a nutshell 

An Operation is an abstract class and should be inherited. An operation may be in one of the following states:<br />
`Pending` - operation is not ready for executing, just waiting.<br />
`Ready` - if you have custom rules for the readiness of your operations you can take control of this status, this status indicates that operation is ready to be executed.<br />
`Executing` - operation is working on it’s task.<br />
`Finished` - if the operation’s task finished execution successfully or if the operation was cancelled.<br />
`Cancelled` - operation does not actively stop the receiver’s code from executing, but the operation isCancelled property returns true. Cannot cancel after finished.<br />
Operations can be executed from a queue. You can add and remove dependencies for an operation. Operations can be synchronous or asynchronous. Operation objects are synchronous by default. In a synchronous operation, the operation object does not create a separate thread on which to run its task.
An asynchronous operation object is responsible for scheduling its task on a separate thread. 

# OperationQueue in a nutshell 

Queue is an abstract data structure open at both its ends. One end is always used to insert data (enqueue) and the other is used to remove data (dequeue). In iOS this structure is represented by OperationQueue class which is a high level wrapper of `dispatch_queue_t`.<br />
  What we can do with a OperationQueue:<br />
  `func addOperations([Operation], waitUntilFinished: Bool)`<br />
  `func cancelAllOperations()`<br />
  `func waitUntilAllOperationsAreFinished()`<br />
  `var maxConcurrentOperationCount: Int` - If set to one, it runs only one operation per time, if default - as many as the system allows.<br />
  `var isSuspended: Bool` - This boolean value indicating whether the queue is actively scheduling and running operations for execution.<br />
By default, NSOperationQueue will do some calculation behind the scenes, decide what is best for the particular platform the code is running on, and will launch the maximum possible number of threads.

# What this project contains?
`OperationManager`<br />
`BaseOperationQueue`<br />
`BaseOperation`<br />
  `NetworkRequestable protocol`<br />
  `DatabaseOperation`<br />
`BaseGroupOperation`<br />

# Project Structure

The **ViewController** knows what operations will be needed for its functionalities and creates them. After creation of the operations, the view controller sends a message to the **OperationsManager** to add and execute them. Each **Operation** is a small unit of work. Once the operation finishes execution, the result is passed to the view controller via the operation manager.

# Interesting links

[Advanced NSOperations // Apple WWDC 2015 link](https://developer.apple.com/videos/play/wwdc2015/226/)

[MVC-N: Isolating network calls from View Controllers // Marcus Zarra 2016 link](https://academy.realm.io/posts/slug-marcus-zarra-exploring-mvcn-swift/)

[NSOperation and NSOperationQueue Tutorial in Swift // Ray Wenderlich link](https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift)


# To Be Done:<br />
Unit Tests<br />
Data Provider<br />
Error handling<br />
Background Context<br />
Request/Response Serializers<br />
...
