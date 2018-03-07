/*:#localized(key: "FirstProseBlock")
 **Goal**: Create a function that accepts a duration – and use that duration to execute your movements.
 
 Below you'll see the `dance(duration:Int)` function. We can see that it accepts a duration, but it still needs to be filled with movement commands. The function will need to execute **at least three** movement commands which each use the `duration` variable.
 
 After it's defined, the function will be called with a random duration value - so we won't know the value of the `duration` variable until the code is running.
 
 **Instructions:**
 1. In the function body, enter **three or more** movement commands which use the `duration` variable's value.
 2. Tap the **Run My Code** button
 
 */
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, moveForward(), turnLeft(), moveBack(), turnRight(), wait())
//#-hidden-code
setup()
//#-end-hidden-code
func dance(duration:Int) {
    //#-hidden-code
    customFunctionCalled()
    //#-end-hidden-code
    //#-editable-code
    <#Enter movement commands here#>
    //#-end-editable-code
}

let value = random(min:1000, max:5000)
dance(duration:value)
//#-hidden-code
exitProgram()
//#-end-hidden-code


