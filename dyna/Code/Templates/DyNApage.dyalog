﻿:Class DyNApage : #.EAWC
⍝ This is a template that "wraps" the page content by
⍝ - adding a header and footer
⍝ - adding a handler that will toggle the display of the web page and its APL source code 

    ∇ Wrap;lang
      :Access Public
     
    ⍝ we use JQuery to set up the handler, so we tell the page to include JQuery resources
      Use'JQuery' ⍝ "JQuery" is a resource defined in Config/Resources.xml
     
    ⍝ set the title display in the browser to the name of the application defined in Config/Server.xml
      Add title _Request.Server.Config.Name
     
    ⍝ add a link to our CSS stylesheet
      (Add link).SetAttr(('href' '/Styles/style.css')('rel' 'stylesheet')('type' 'text/css'))
     
    ⍝ set a meta tag to make it explicitly UTF-8
      (Add meta).SetAttr'http-equiv="content-type" content="text/html;charset=UTF-8"'
     
    ⍝ wrap the content of the <body> element in a div
      Body.Push div'id="contentblock"'
     
    ⍝ add a hidden division to the body containing the APL source code
      (Add div(#.HTMLInput.APLToHTML ⎕SRC⊃⊃⎕CLASS ⎕THIS)).SetAttr'id="codeblock" style="display: none;"'
     
    ⍝ add a JQuery event handler to toggle the web page/APL source code
      Add Script'$(function(){$("#bannerimage").on("click", function(evt){$("#contentblock,#codeblock").toggle();});});'
     
    ⍝ add the footer to the bottom of the page
      Add #.Files.GetText _Request.Server.Config.Root,'Styles\footer.txt'
     
    ⍝ add the header to the top of the page and wrap the body in a div with id="wrapper"
      Body.Push #.Files.GetText _Request.Server.Config.Root,'Styles\banner.txt'
      Body.Push div'id="wrapper"'
     
    ⍝ call the base class Wrap function
      ⎕BASE.Wrap
    ∇

:EndClass
