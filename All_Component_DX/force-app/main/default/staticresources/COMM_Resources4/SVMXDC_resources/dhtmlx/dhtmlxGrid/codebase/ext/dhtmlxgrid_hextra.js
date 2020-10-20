//v.3.6 build 131108

/*
Copyright DHTMLX LTD. http://www.dhtmlx.com
To use this component please contact sales@dhtmlx.com to obtain license
*/
dhtmlXGridObject.prototype._in_header_collapse=function(b,e,d){var a=b.tagName=="TD"?b:b.parentNode,e=a._cellIndexS;if(!this._column_groups)this._column_groups=[];var c=d[1].split(":"),c=d[1].split(":"),c=[c.shift(),c.join(":")],h=parseInt(c[0]);b.innerHTML=d[0]+"<img src='"+this.imgURL+"minus.gif' style='padding-right:10px;height:16px'/><span style='position:relative; top:-6px;'>"+(c[1]||"")+"<span>";b.style.paddingBottom="0px";var g=this;this._column_groups[e]=b.getElementsByTagName("IMG")[0];this._column_groups[e].onclick=
function(b){(b||event).cancelBubble=!0;this._cstate=!this._cstate;for(var c=e+1;c<e+h;c++)g.setColumnHidden(c,this._cstate);if(this._cstate){if(a.colSpan&&a.colSpan>0){a._exp_colspan=a.colSpan;var d=Math.max(1,a.colSpan-h);if(!_isFF)for(var f=0;f<a.colSpan-d;f++){var i=document.createElement("TD");a.nextSibling?a.parentNode.insertBefore(i,a.nextSibling):a.parentNode.appendChild(i)}a.colSpan=d}}else if(a._exp_colspan&&(a.colSpan=a._exp_colspan,!_isFF))for(f=1;f<a._exp_colspan;f++)a.parentNode.removeChild(a.nextSibling);
this.src=g.imgURL+(this._cstate?"plus.gif":"minus.gif");g.sortImg.style.display!="none"&&g.setSortImgPos()}};dhtmlXGridObject.prototype.collapseColumns=function(b){if(this._column_groups[b])this._column_groups[b]._cstate=!1,this._column_groups[b].onclick({})};dhtmlXGridObject.prototype.expandColumns=function(b){if(this._column_groups[b])this._column_groups[b]._cstate=!0,this._column_groups[b].onclick({})};

//v.3.6 build 131108

/*
Copyright DHTMLX LTD. http://www.dhtmlx.com
To use this component please contact sales@dhtmlx.com to obtain license
*/