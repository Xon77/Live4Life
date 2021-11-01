/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Wouter Snoei.

    GameOfLife WFSCollider software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    GameOfLife WFSCollider is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GameOfLife WFSCollider.  If not, see <http://www.gnu.org/licenses/>.
*/

+ UScore{

	*openWFS{ |path, action|
	    var score;
        var f = { |path,action|

		         if( File(path,"r").readAllString[..8] == "<xml:wfs>") {
                    score = WFSScore.readWFSFile(path).asUEvent;
                    action.value(score);
                    score
	             } {
	                score = this.readTextArchive( path );
	                action.value(score);
	                score
	             }

        };
        if( path.isNil ) {
		    Dialog.getPaths( { |paths|
		        f.(paths[0],action);
		    });
	    } {
            path = path.standardizePath;
            f.(path,action)
	    };
	}
}