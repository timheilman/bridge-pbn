* fix bug: multiple emits for each event on second+ call to import
* fix bug: fourth-seat opens are incorrectly marked complete? (in auction section, compute is completed)
* include Tis's tests, commenting-out those needing it
* TDD refactor duplicated intent: parameterization by type, in injector; standardize the call
* enforce section continuity: no identification section tags both before and after play/auction/supplemental
* enforce 255 char cap on line width
* TDD erroring out descriptively for edge case: open curly (and semicolon) not-first on line and not-after space
* TDD known bug: double quotes and backslashes within string tokens aren't forwarded properly for sections
* test edge case with multiple \n's
* see section 4.8; TDD handling of # and ## tag values
* 100% implementation of Tis's tests (TDD finer scale to match each test, as an acceptance test)