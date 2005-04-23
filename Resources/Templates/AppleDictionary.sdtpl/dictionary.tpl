<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>@Name!</title>
  @Style-Link!
  <!-- @Start:Style! -->
  <style type="text/css">
   @Style-Sheet!
  </style>
  <!-- @End! -->
 </head>
 <body>
  @Anchor!
  <h1>@Name!</h1>
   <!-- @Start:Suite! -->
    @Anchor!
    <span class="suite_name">@Name!: </span><span class="suite_description">@Description!</span>
    <!-- @Start:Classes! -->
    <dl class="class_block">
     <!-- @Start:Class! -->
     @Anchor!
     <dt class="class_title"><strong>Class @Name!: </strong>@Description!</dt>
     <dd>
      <!-- @Start:Plural! -->
      Plural form:<br />
        <div class="app_word" style="margin-left: 2em">@Name!</div>
      <!-- @End! -->
      <!-- @Start:Subclasses! -->
      Subclasses:
      <ul class="subclasses">
       	<!-- @Start:Subclass! -->
       	<li>@Name!</li> 	     	<!-- @End! Subclass-->
      </ul>
      <!-- @End! Subclasses -->
      <!-- @Start:Elements! -->
      Elements:
      <ul class="elements">
       <!-- @Start:Element! -->
       <li><span class="app_word">@Type!</span> @Accessors!</li> 	     <!-- @End! -->
 	    </ul>
 	    <!-- @End! -->
 	    <!-- @Start:Properties! -->     Properties:
      <ul class="properties">
       <!-- @Start:Superclass! -->
       <li><span class="app_word">&lt;Inheritance&gt;</span> 
       <span class="lang_word">@Name!</span> [r/o]
       <span class="description">-- inherits some of its properties from the @Description! class</span></li>
       <!-- @End! Superclass -->
       <!-- @Start:Property! -->
       <li><span class="app_word">@Name!</span> 
       <span class="lang_word">@Type!</span>  @Read-Only! 
       <span class="description">@Description!</span></li>
       <!-- @End! Property -->
 	    </ul>
 	    <!-- @End! Properties -->
 	    
 	    <!-- @Start:Responds-To-Commands! -->      Responds to Commands:
      <ul class="properties">
       <!-- @Start:Responds-To-Command! -->
       <li><span class="app_word">@Name!</span>
       	<span class="description">@Description!</span></li>
       <!-- @End! Responds-To-Command -->
 	    </ul>
 	    <!-- @End! Responds-To-Commands -->
 	    
 	    <!-- @Start:Responds-To-Events! -->      Responds to Events:
      <ul class="properties">
       <!-- @Start:Responds-To-Event! -->
       <li><span class="app_word">@Name!</span>
       	<span class="description">@Description!</span></li>
       <!-- @End! Responds-To-Event -->
 	    </ul>
 	    <!-- @End! Responds-To-Events -->
	    </dd>
    <!-- @End! Class -->
	   </dl>
	   <!-- @End! Classes -->
	   
	   <!-- @Start:Commands! -->
	   Commands:
	   <dl class="command_block">
    <!-- @Start:Command! -->
     @Anchor!
     <dt class="command_title"><strong>@Name!: </strong>@Description!</dt>
     <dd>
	     <span class="app_word">@Name!</span>
	     <!-- @Start:Direct-Parameter! -->
	     @Type-List!&nbsp;<span class="lang_word">@Type!</span>
	     &nbsp;<span class="description">@Description!</span>
	     <!-- @End! -->
	     <!-- @Start:Parameters! -->
	     <ul class="parameters">
	      <!-- @Start:Required-Parameter! -->
		     <li><span class="app_word">@Name!</span>
		     @Type-List!&nbsp;<span class="lang_word">@Type!</span>
		     &nbsp;<span class="description">@Description!</span></li>
		     <!-- @End! -->
		     <!-- @Start:Optional-Parameter! -->
		     <li>[<span class="app_word">@Name!</span>
		     @Type-List!&nbsp;<span class="lang_word">@Type!</span>]
		     &nbsp;<span class="description">@Description!</span></li>
		     <!-- @End! -->
		    </ul>
		    <!-- @End! Parameters -->
		    <!-- @Start:Result! -->
	    <div class="result">Result:
	     @Type-List!&nbsp;<span class="lang_word">@Type!</span>
	     &nbsp;<span class="description">@Description!</span></div>
	     <!-- @End! Result -->
     </dd>
    <!-- @End! Command -->
    </dl>
   <!-- @End! Commands -->
   
   <!-- @Start:Events! -->
    Events:
	   <dl class="command_block">
    <!-- @Start:Event! -->
     @Anchor!
     <dt class="command_title"><strong>@Name!: </strong>@Description!</dt>
     <dd>
	     <span class="app_word">@Name!</span>
	     <!-- @Start:Direct-Parameter! -->
	     @Type-List!&nbsp;<span class="lang_word">@Type!</span>
	     &nbsp;<span class="description">@Description!</span>
	     <!-- @End! -->
	     <!-- @Start:Parameters! -->
	     <ul class="parameters">
	      <!-- @Start:Required-Parameter! -->
		     <li><span class="app_word">@Name!</span>
		     @Type-List!&nbsp;<span class="lang_word">@Type!</span>
		     &nbsp;<span class="description">@Description!</span></li>
		     <!-- @End! -->
		     <!-- @Start:Optional-Parameter! -->
		     <li>[<span class="app_word">@Name!</span>
		     @Type-List!&nbsp;<span class="lang_word">@Type!</span>]
		     &nbsp;<span class="description">@Description!</span></li>
		     <!-- @End! -->
		    </ul>
		    <!-- @End! Parameters -->
		    <!-- @Start:Result! -->
	    <div class="result">Result:
	     @Type-List!&nbsp;<span class="lang_word">@Type!</span>
	     &nbsp;<span class="description">@Description!</span></div>
	     <!-- @End! Result -->
     </dd>
    <!-- @End! Event -->
    </dl>
   <!-- @End! Events -->
   
   <!-- @End! Suite -->
 </body>
</html>