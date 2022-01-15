<?php
/*	--------------------------------------------------------------------------------
	Supercollider PHP syntax highlighter V0.9.5
	sc_highlighting.php
	21 September 2009
	Updated: 8 April 2016
	
	Written by Adam Jansch - http://www.adamjansch.co.uk
	Based on code from Scott Hewitt's ChucK Highlighter (http://www.ablelemon.co.uk/static.php?page=chuckhl)
	
	Copyright (c) 2009, Adam Jansch
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright
	      notice, this list of conditions and the following disclaimer in the
	      documentation and/or other materials provided with the distribution.
	    * Neither the name of the names of its contributors may be used to endorse
	      or promote products derived from this software without specific prior
	      written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL ADAM JANSCH BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
	Default SC syntax colouring:
	• Blue - keywords (arg, var, etc.) and Class names (SinOsc, Out, etc.)
	• Green - literals (within ' ') and \names
	• Grey - contents of ""
	• Red - comments
	• not explicitly styled - everything else
	
	TO DO: Make sure code in "" and '' isn't affected by other colourising
	--------------------------------------------------------------------------------	*/

function colourise($in_string)
{
	// Colourise text within double quotes
	$pattern = '#\"([^\"]*)\"#';
	$codestring = preg_replace($pattern, '<span class="doublequotes">$0</span>', $in_string);
	
	// Colourise text within single quotes
	$pattern = '#\'([^\']*)\'#';
	$codestring = preg_replace($pattern, '<span class="singlequotes">$0</span>', $codestring);
	
	// Colourise \names
	$pattern = '#\\\(\w*)#';
	$codestring = preg_replace($pattern, '<span class="singlequotes">$0</span>', $codestring);
	
	// Colourise |arg declarations|
	$pattern = '#\|.*\|#';
	$codestring = preg_replace($pattern, '<span class="keyword">$0</span>', $codestring);
	
	// Colourise class names
	$pattern = '#(?<=[\s|\[|\(|\{])([A-Z]\w*)#';	// Includes positive lookbehind for \s chars, [, ( or {
	$codestring = preg_replace($pattern, '<span class="keyword">$0</span>', $codestring);
	
	// Declare keyword array (regex)
	$keywords = array('\sarg ', '\svar ', '\sclassvar ', 'true', 'false', 'nil', 'inf', 'rgb', 'thisProcess', 'thisThread', 'thisSynth', 'thisFunction', 'thisMethod');
	
	foreach($keywords as $keyword_regex)
	{
		// Pattern must exclude keywords found within other words, like 'inf' in 'infinite'
		$pattern =	'# '.$keyword_regex.' |'.$keyword_regex.';|='.$keyword_regex.'#';
		$codestring = preg_replace($pattern, '<span class="keyword">$0</span>', $codestring);
	}
	
	return $codestring;
}




// Takes in file path and opens file for processing by string highlighting function
function sc_highlight_file($file_path)
{
	// Open file from argument --------------------------------------------------
	$codestring = file_get_contents($file_path);	
	
  return sc_highlight_string($codestring);
}




// Function to highlight a string
function sc_highlight_string($code_string)
{
  $code_array = explode("\n", $code_string);
	$multiline_comment = 0;
	$highlighted = "<pre><code>";
	
	
	// Go through code line by line to separate comments from code
	foreach($code_array as $unescaped_code_line)
	{	
  	$code_line = htmlspecialchars($unescaped_code_line);
  		
		if($multiline_comment == 1)
		{
			$mline_index = strrpos($code_line, "*/");
			
			if(is_integer($mline_index))
			{
				$highlighted .= $code_line."</span>";
				$multiline_comment = 0;
			}
			else
				$highlighted .= $code_line;
		}
		else
		{
			$mline_index = strrpos($code_line, "/*");
			
			if(is_integer($mline_index))
			{
				$multiline_comment = 1;
				
				// If return is 0 then comment takes whole line, otherwise line is mixed
				if($mline_index == 0)
				{
					$highlighted .= '<span class="comment">'.$code_line;
				}
				else
				{
					// Split line at // for separate formatting
					$mixed_line = explode("/*", $code_line);
				
					// Colourise first part of line then add comment formatting
					$highlighted .= colourise($mixed_line[0]).'<span class="comment">//'.$mixed_line[1];
				}
				
				$mline_end_index = strrpos($code_line, "*/");
				
				if(is_integer($mline_end_index))
				{
					$highlighted .= "</span>";
					$multiline_comment = 0;
				}
					
			}
			else
			{
				// Search line for // comment
				$dbrack_index = strrpos($code_line, "//");
				
				// If present the return will be an integer, blank otherwise
				if(is_integer($dbrack_index))
				{
					// If return is 0 then comment takes whole line, otherwise line is mixed
					if($dbrack_index == 0)
					{
						$highlighted .= '<span class="comment">'.$code_line."</span>";
				  }
					else
					{
						// Split line at // for separate formatting
						$mixed_line = explode("//", $code_line);
					
						// Colourise first part of line then add comment formatting
						$highlighted .= colourise($mixed_line[0]).'<span class="comment">//'.$mixed_line[1]."</span>";
					}
				}
				else
				{
					$highlighted .= colourise($code_line);
				}
			}
		}
		
		$highlighted .= "\n";
	}
	
	// End code block formatting ------------------------------------------------
	$highlighted .= '</code></pre>';
	
	return $highlighted;
}




// Function to add stylesheet
function sc_add_stylesheet($prepath)
{
	// Add link to syntax CSS file ==============================================
	echo '<link rel="stylesheet" type="text/css" href="'.$prepath.'sc_highlighting.css" />'."\n\n";
}













// DEPRECATED! //
// ORIGINAL HIGHLIGHTER FUNCTION – ECHOES RATHER THAN RETURNS, SWITCH TO sc_highlight_file($file_path)
// Takes in file path and opens file for processing by string highlighting function
function sc_highlighter($file_path)
{
	// STRING REPLACEMENT =======================================================
	// Place automatic code block formatting ------------------------------------
	echo "<pre>\n<code>";
	
	// Open file from argument --------------------------------------------------
	$codestring = file_get_contents($file_path);	
	
	$codestring_arr = explode("\n", $codestring);
	
	$multiline_comment = 0;
	
	// Go through code line by line to separate comments from code
	foreach($codestring_arr as $code_line)
	{		
		if($multiline_comment == 1)
		{
			$mline_index = strrpos($code_line, "*/");
			
			if(is_integer($mline_index))
			{
				echo $code_line."</div>";
				$multiline_comment = 0;
			}
			else
				echo $code_line;
		}
		else
		{
			$mline_index = strrpos($code_line, "/*");
			
			if(is_integer($mline_index))
			{
				$multiline_comment = 1;
				
				// If return is 0 then comment takes whole line, otherwise line is mixed
				if($mline_index == 0)
					echo '<div class="comment">'.$code_line;
				else
				{
					// Split line at // for separate formatting
					$mixed_line = explode("/*", $code_line);
				
					// Colourise first part of line then add comment formatting
					echo colourise($mixed_line[0]).'<div class="comment">//'.$mixed_line[1];
				}
				
				$mline_end_index = strrpos($code_line, "*/");
				
				if(is_integer($mline_end_index))
				{
					echo "</div>";
					$multiline_comment = 0;
				}
					
			}
			else
			{
				// Search line for // comment
				$dbrack_index = strrpos($code_line, "//");
				
				// If present the return will be an integer, blank otherwise
				if(is_integer($dbrack_index))
				{
					// If return is 0 then comment takes whole line, otherwise line is mixed
					if($dbrack_index == 0)
						echo '<span class="comment">'.$code_line."</span>";
					else
					{
						// Split line at // for separate formatting
						$mixed_line = explode("//", $code_line);
					
						// Colourise first part of line then add comment formatting
						echo colourise($mixed_line[0]).'<span class="comment">//'.$mixed_line[1]."</span>";
					}
				}
				else
					echo colourise($code_line);
			}
		}
		
		echo "\n";
	}
	
	// End code block formatting ------------------------------------------------
	echo "</pre>";
}

?>