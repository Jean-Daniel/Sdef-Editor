<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>@Dictionary_Name!</title>
  <style type="text/css">
   @Style_Sheet!
  </style>
 </head>
 <body>
  <h1>@Dictionary_Name!</h1>
   <!-- @Start:Suite! -->
    @Suite_Anchor!
    <span class="suite_name">@Suite_Name!: </span><span class="suite_description">@Suite_Description!</span>
    <!-- @Start:Classes! -->
    <dl class="class_block">
     <!-- @Start:Class! -->
     @Class_Anchor!
     <dt class="class_title"><strong>Class @Class_Name!: </strong>@Class_Description!</dt>
     <dd>
      <!-- @Start:Plural! -->
      Plural form:<br />
        <div class="app_word" style="margin-left: 2em">@Plural!</div>
      <!-- @End! -->
      <!-- @Start:Subclasses! -->
      Subclasses:
      <ul class="subclasses">
       	<!-- @Start:Subclass! -->
       	<li>@Subclass!</li> 	     	<!-- @End! Subclass-->
      </ul>
      <!-- @End! Subclasses -->
      <!-- @Start:Elements! -->
      Elements:
      <ul class="elements">
       <!-- @Start:Element! -->
       <li><span class="app_word">@Element_Type!</span> @Element_Accessors!</li> 	     <!-- @End! -->
 	    </ul>
 	    <!-- @End! -->
 	    <!-- @Start:Properties! -->     Properties:
      <ul class="properties">
       <!-- @Start:Superclass! -->
       <li><span class="app_word">&lt;Inheritance&gt;</span> 
       <span class="lang_word">@Superclass!</span> [r/o]
       <span class="description">@Superclass_Description!</span></li>
       <!-- @End! Superclass -->
       <!-- @Start:Property! -->
       <li><span class="app_word">@Property_Name!</span> 
       <span class="lang_word">@Property_Type!</span>  @ReadOnly! 
       <span class="description">@Property_Description!</span></li>
       <!-- @End! Property -->
 	    </ul>
 	    <!-- @End! Properties -->
	    </dd>
    <!-- @End! Class -->
	   </dl>
	   <!-- @End! Classes -->
	   <!-- @Start:Commands! -->
	   <dl class="command_block">
    <!-- @Start:Command! -->
     @Command_Anchor!
     <dt class="command_title"><strong>@Command_Name!: </strong>@Command_Description!</dt>
     <dd>
	     <span class="app_word">@Command_Name!</span>
	     <!-- @Start:Direct_Parameter! -->
	     @Direct_Parameter_List!&nbsp;<span class="lang_word">@Direct_Parameter!</span>
	     &nbsp;<span class="description">@Direct_Parameter_Description!</span>
	     <!-- @End! -->
	     <!-- @Start:Parameters! -->
	     <ul class="parameters">
	      <!-- @Start:Required_Parameter! -->
		     <li><span class="app_word">@Parameter_Name!</span>
		     @Parameter_Type_List! <span class="lang_word">@Parameter_Type!</span>
		     <span class="description">@Parameter_Description!</span></li>
		     <!-- @End! -->
		     <!-- @Start:Optional_Parameter! -->
		     <li>[<span class="app_word">@Parameter_Name!</span>  <span class="lang_word">@Parameter_Type!</span>]
		     <span class="description">@Parameter_Description!</span></li>
		     <!-- @End! -->
		    </ul>
		    <!-- @End! Parameters -->
		    <!-- @Start:Result! -->
	    <div class="result">Result:
	     @Result_Type_List!&nbsp;<span class="lang_word">@Result_Type!</span>
	     &nbsp;<span class="description">@Result_Description!</span></div>
	     <!-- @End! Result -->
     </dd>
    <!-- @End! Command -->
    </dl>
   <!-- @End! Commands -->
   <!-- @End! Suite -->
 </body>
</html>