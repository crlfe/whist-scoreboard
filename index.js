!function(e){var t={};function n(o){if(t[o])return t[o].exports;var r=t[o]={i:o,l:!1,exports:{}};return e[o].call(r.exports,r,r.exports,n),r.l=!0,r.exports}n.m=e,n.c=t,n.d=function(e,t,o){n.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:o})},n.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},n.t=function(e,t){if(1&t&&(e=n(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var o=Object.create(null);if(n.r(o),Object.defineProperty(o,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)n.d(o,r,function(t){return e[t]}.bind(null,r));return o},n.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(t,"a",t),t},n.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},n.p="",n(n.s=1)}([function(e,t,n){},function(e,t,n){"use strict";n.r(t);n(0);var o,r,l,u,i,c={},s=[],a=/acit|ex(?:s|g|n|p|$)|rph|grid|ows|mnc|ntw|ine[ch]|zoo|^ord/i;function _(e,t){for(var n in t)e[n]=t[n];return e}function f(e){var t=e.parentNode;t&&t.removeChild(e)}function p(e,t,n){var o,r,l,u,i=arguments;if(t=_({},t),arguments.length>3)for(n=[n],o=3;o<arguments.length;o++)n.push(i[o]);if(null!=n&&(t.children=n),null!=e&&null!=e.defaultProps)for(r in e.defaultProps)void 0===t[r]&&(t[r]=e.defaultProps[r]);return u=t.key,null!=(l=t.ref)&&delete t.ref,null!=u&&delete t.key,d(e,t,u,l)}function d(e,t,n,r){var l={type:e,props:t,key:n,ref:r,__k:null,__:null,__b:0,__e:null,__d:null,__c:null,constructor:void 0};return o.vnode&&o.vnode(l),l}function m(e){return e.children}function h(e,t){this.props=e,this.context=t}function y(e,t){if(null==t)return e.__?y(e.__,e.__.__k.indexOf(e)+1):null;for(var n;t<e.__k.length;t++)if(null!=(n=e.__k[t])&&null!=n.__e)return n.__e;return"function"==typeof e.type?y(e):null}function v(e){var t,n;if(null!=(e=e.__)&&null!=e.__c){for(e.__e=e.__c.base=null,t=0;t<e.__k.length;t++)if(null!=(n=e.__k[t])&&null!=n.__e){e.__e=e.__c.base=n.__e;break}return v(e)}}function b(e){(!e.__d&&(e.__d=!0)&&1===r.push(e)||u!==o.debounceRendering)&&((u=o.debounceRendering)||l)(g)}function g(){var e,t,n,o,l,u,i;for(r.sort((function(e,t){return t.__v.__b-e.__v.__b}));e=r.pop();)e.__d&&(n=void 0,o=void 0,u=(l=(t=e).__v).__e,(i=t.__P)&&(n=[],o=A(i,l,_({},l),t.__n,void 0!==i.ownerSVGElement,null,n,null==u?y(l):u),C(n,l),o!=u&&v(l)))}function w(e,t,n,o,r,l,u,i,a){var _,p,d,m,h,v,b,g=n&&n.__k||s,w=g.length;if(i==c&&(i=null!=l?l[0]:w?y(n,0):null),_=0,t.__k=k(t.__k,(function(n){if(null!=n){if(n.__=t,n.__b=t.__b+1,null===(d=g[_])||d&&n.key==d.key&&n.type===d.type)g[_]=void 0;else for(p=0;p<w;p++){if((d=g[p])&&n.key==d.key&&n.type===d.type){g[p]=void 0;break}d=null}if(m=A(e,n,d=d||c,o,r,l,u,i,a),(p=n.ref)&&d.ref!=p&&(b||(b=[]),d.ref&&b.push(d.ref,null,n),b.push(p,n.__c||m,n)),null!=m){if(null==v&&(v=m),null!=n.__d)m=n.__d,n.__d=null;else if(l==d||m!=i||null==m.parentNode){e:if(null==i||i.parentNode!==e)e.appendChild(m);else{for(h=i,p=0;(h=h.nextSibling)&&p<w;p+=2)if(h==m)break e;e.insertBefore(m,i)}"option"==t.type&&(e.value="")}i=m.nextSibling,"function"==typeof t.type&&(t.__d=m)}}return _++,n})),t.__e=v,null!=l&&"function"!=typeof t.type)for(_=l.length;_--;)null!=l[_]&&f(l[_]);for(_=w;_--;)null!=g[_]&&E(g[_],g[_]);if(b)for(_=0;_<b.length;_++)P(b[_],b[++_],b[++_])}function k(e,t,n){if(null==n&&(n=[]),null==e||"boolean"==typeof e)t&&n.push(t(null));else if(Array.isArray(e))for(var o=0;o<e.length;o++)k(e[o],t,n);else n.push(t?t("string"==typeof e||"number"==typeof e?d(null,e,null,null):null!=e.__e||null!=e.__c?d(e.type,e.props,e.key,null):e):e);return n}function S(e,t,n){"-"===t[0]?e.setProperty(t,n):e[t]="number"==typeof n&&!1===a.test(t)?n+"px":null==n?"":n}function T(e,t,n,o,r){var l,u,i,c,s;if(r?"className"===t&&(t="class"):"class"===t&&(t="className"),"key"===t||"children"===t);else if("style"===t)if(l=e.style,"string"==typeof n)l.cssText=n;else{if("string"==typeof o&&(l.cssText="",o=null),o)for(u in o)n&&u in n||S(l,u,"");if(n)for(i in n)o&&n[i]===o[i]||S(l,i,n[i])}else"o"===t[0]&&"n"===t[1]?(c=t!==(t=t.replace(/Capture$/,"")),s=t.toLowerCase(),t=(s in e?s:t).slice(2),n?(o||e.addEventListener(t,x,c),(e.l||(e.l={}))[t]=n):e.removeEventListener(t,x,c)):"list"!==t&&"tagName"!==t&&"form"!==t&&!r&&t in e?e[t]=null==n?"":n:"function"!=typeof n&&"dangerouslySetInnerHTML"!==t&&(t!==(t=t.replace(/^xlink:?/,""))?null==n||!1===n?e.removeAttributeNS("http://www.w3.org/1999/xlink",t.toLowerCase()):e.setAttributeNS("http://www.w3.org/1999/xlink",t.toLowerCase(),n):null==n||!1===n?e.removeAttribute(t):e.setAttribute(t,n))}function x(e){this.l[e.type](o.event?o.event(e):e)}function A(e,t,n,r,l,u,i,c,s){var a,f,p,d,y,v,b,g,S,T,x=t.type;if(void 0!==t.constructor)return null;(a=o.__b)&&a(t);try{e:if("function"==typeof x){if(g=t.props,S=(a=x.contextType)&&r[a.__c],T=a?S?S.props.value:a.__:r,n.__c?b=(f=t.__c=n.__c).__=f.__E:("prototype"in x&&x.prototype.render?t.__c=f=new x(g,T):(t.__c=f=new h(g,T),f.constructor=x,f.render=N),S&&S.sub(f),f.props=g,f.state||(f.state={}),f.context=T,f.__n=r,p=f.__d=!0,f.__h=[]),null==f.__s&&(f.__s=f.state),null!=x.getDerivedStateFromProps&&(f.__s==f.state&&(f.__s=_({},f.__s)),_(f.__s,x.getDerivedStateFromProps(g,f.__s))),d=f.props,y=f.state,p)null==x.getDerivedStateFromProps&&null!=f.componentWillMount&&f.componentWillMount(),null!=f.componentDidMount&&f.__h.push(f.componentDidMount);else{if(null==x.getDerivedStateFromProps&&null==f.__e&&null!=f.componentWillReceiveProps&&f.componentWillReceiveProps(g,T),!f.__e&&null!=f.shouldComponentUpdate&&!1===f.shouldComponentUpdate(g,f.__s,T)){for(f.props=g,f.state=f.__s,f.__d=!1,f.__v=t,t.__e=n.__e,t.__k=n.__k,f.__h.length&&i.push(f),a=0;a<t.__k.length;a++)t.__k[a]&&(t.__k[a].__=t);break e}null!=f.componentWillUpdate&&f.componentWillUpdate(g,f.__s,T),null!=f.componentDidUpdate&&f.__h.push((function(){f.componentDidUpdate(d,y,v)}))}f.context=T,f.props=g,f.state=f.__s,(a=o.__r)&&a(t),f.__d=!1,f.__v=t,f.__P=e,a=f.render(f.props,f.state,f.context),t.__k=k(null!=a&&a.type==m&&null==a.key?a.props.children:a),null!=f.getChildContext&&(r=_(_({},r),f.getChildContext())),p||null==f.getSnapshotBeforeUpdate||(v=f.getSnapshotBeforeUpdate(d,y)),w(e,t,n,r,l,u,i,c,s),f.base=t.__e,f.__h.length&&i.push(f),b&&(f.__E=f.__=null),f.__e=null}else t.__e=G(n.__e,t,n,r,l,u,i,s);(a=o.diffed)&&a(t)}catch(e){o.__e(e,t,n)}return t.__e}function C(e,t){o.__c&&o.__c(t,e),e.some((function(t){try{e=t.__h,t.__h=[],e.some((function(e){e.call(t)}))}catch(e){o.__e(e,t.__v)}}))}function G(e,t,n,o,r,l,u,i){var a,_,f,p,d,m=n.props,h=t.props;if(r="svg"===t.type||r,null==e&&null!=l)for(a=0;a<l.length;a++)if(null!=(_=l[a])&&(null===t.type?3===_.nodeType:_.localName===t.type)){e=_,l[a]=null;break}if(null==e){if(null===t.type)return document.createTextNode(h);e=r?document.createElementNS("http://www.w3.org/2000/svg",t.type):document.createElement(t.type),l=null}if(null===t.type)null!=l&&(l[l.indexOf(e)]=null),m!==h&&(e.data=h);else if(t!==n){if(null!=l&&(l=s.slice.call(e.childNodes)),f=(m=n.props||c).dangerouslySetInnerHTML,p=h.dangerouslySetInnerHTML,!i){if(m===c)for(m={},d=0;d<e.attributes.length;d++)m[e.attributes[d].name]=e.attributes[d].value;(p||f)&&(p&&f&&p.__html==f.__html||(e.innerHTML=p&&p.__html||""))}(function(e,t,n,o,r){var l;for(l in n)l in t||T(e,l,null,n[l],o);for(l in t)r&&"function"!=typeof t[l]||"value"===l||"checked"===l||n[l]===t[l]||T(e,l,t[l],n[l],o)})(e,h,m,r,i),t.__k=t.props.children,p||w(e,t,n,o,"foreignObject"!==t.type&&r,l,u,c,i),i||("value"in h&&void 0!==h.value&&h.value!==e.value&&(e.value=null==h.value?"":h.value),"checked"in h&&void 0!==h.checked&&h.checked!==e.checked&&(e.checked=h.checked))}return e}function P(e,t,n){try{"function"==typeof e?e(t):e.current=t}catch(e){o.__e(e,n)}}function E(e,t,n){var r,l,u;if(o.unmount&&o.unmount(e),(r=e.ref)&&P(r,null,t),n||"function"==typeof e.type||(n=null!=(l=e.__e)),e.__e=e.__d=null,null!=(r=e.__c)){if(r.componentWillUnmount)try{r.componentWillUnmount()}catch(e){o.__e(e,t)}r.base=r.__P=null}if(r=e.__k)for(u=0;u<r.length;u++)r[u]&&E(r[u],t,n);null!=l&&f(l)}function N(e,t,n){return this.constructor(e,n)}function M(e,t,n){var r,l,u;o.__&&o.__(e,t),l=(r=n===i)?null:n&&n.__k||t.__k,e=p(m,null,[e]),u=[],A(t,(r?t:n||t).__k=e,l||c,c,void 0!==t.ownerSVGElement,n&&!r?[n]:l?null:s.slice.call(t.childNodes),u,n||c,r),C(u,e)}o={__e:function(e,t){for(var n;t=t.__;)if((n=t.__c)&&!n.__)try{if(n.constructor&&null!=n.constructor.getDerivedStateFromError)n.setState(n.constructor.getDerivedStateFromError(e));else{if(null==n.componentDidCatch)continue;n.componentDidCatch(e)}return b(n.__E=n)}catch(t){e=t}throw e}},h.prototype.setState=function(e,t){var n;n=this.__s!==this.state?this.__s:this.__s=_({},this.state),"function"==typeof e&&(e=e(n,this.props)),e&&_(n,e),null!=e&&this.__v&&(this.__e=!1,t&&this.__h.push(t),b(this))},h.prototype.forceUpdate=function(e){this.__v&&(this.__e=!0,e&&this.__h.push(e),b(this))},h.prototype.render=m,r=[],l="function"==typeof Promise?Promise.prototype.then.bind(Promise.resolve()):setTimeout,i=c;var D,O,H,I=[],R=o.__r,U=o.diffed,$=o.__c,j=o.unmount;function F(e){o.__h&&o.__h(O);var t=O.__H||(O.__H={t:[],u:[]});return e>=t.t.length&&t.t.push({}),t.t[e]}function L(e){return function(e,t,n){var o=F(D++);return o.__c||(o.__c=O,o.i=[n?n(t):z(void 0,t),function(t){var n=e(o.i[0],t);o.i[0]!==n&&(o.i[0]=n,o.__c.setState({}))}]),o.i}(z,e)}function W(e,t){var n=F(D++);return V(n.o,t)?(n.o=t,n.v=e,n.i=e()):n.i}function K(e,t){return W((function(){return e}),t)}function q(){I.some((function(e){e.__P&&(e.__H.u.forEach(B),e.__H.u.forEach(J),e.__H.u=[])})),I=[]}function B(e){e.m&&e.m()}function J(e){var t=e.i();"function"==typeof t&&(e.m=t)}function V(e,t){return!e||t.some((function(t,n){return t!==e[n]}))}function z(e,t){return"function"==typeof t?t(e):t}function Q({numTables:e,numGames:t,onOpen:n,onSave:o,onClear:r,onAddGame:l,onRemoveGame:u,onSetTables:i,onSetGames:c}){return[p("tr",{},[p("th",{class:"hdr-table",scope:"col"},["Table",p("div",{class:"tools-left"},[p("button",{},"Menu"),p("ul",{},[p("li",{class:"input-grid"},[p("label",{for:"numTables"},"Tables"),p("input",{id:"numTables",type:"number",min:"1",max:"100",value:e,onChange:K(t=>{const n=t.target;i(n.value),n.value=String(e)},[i])}),p("label",{for:"numGames"},"Games"),p("input",{id:"numGames",type:"number",min:"1",max:"100",value:t,onChange:K(e=>{const n=e.target;c(n.value),n.value=String(t)},[c])})]),p("li",{},p("button",{onClick:n},"Open...")),p("li",{},p("button",{onClick:o},"Save As...")),p("li",{},p("button",{onClick:r},"Clear"))])])]),p("th",{class:"hdr-games",colspan:t+1,scope:"colgroup"},[p("span",{class:"title"},"Games")]),p("th",{class:"hdr-total",scope:"col"},["Total",p("div",{class:"tools-right"},[p("button",{title:"Remove Game",onClick:u},"-"),p("button",{title:"Add Game",onClick:l},"+")])])]),p("tr",{},[p("td",{class:"hdr-table"}),Array.from({length:t},(e,t)=>p("th",{class:"hdr-game",id:`game-${t}`},`${t+1}`)),p("td",{class:"col-stretch"}),p("td",{class:"hdr-total"})])]}o.__r=function(e){R&&R(e),D=0,(O=e.__c).__H&&(O.__H.u.forEach(B),O.__H.u.forEach(J),O.__H.u=[])},o.diffed=function(e){U&&U(e);var t=e.__c;if(t){var n=t.__H;n&&n.u.length&&(1!==I.push(t)&&H===o.requestAnimationFrame||((H=o.requestAnimationFrame)||function(e){var t,n=function(){clearTimeout(o),cancelAnimationFrame(t),setTimeout(e)},o=setTimeout(n,100);"undefined"!=typeof window&&(t=requestAnimationFrame(n))})(q))}},o.__c=function(e,t){t.some((function(e){e.__h.forEach(B),e.__h=e.__h.filter((function(e){return!e.i||J(e)}))})),$&&$(e,t)},o.unmount=function(e){j&&j(e);var t=e.__c;if(t){var n=t.__H;n&&n.t.forEach((function(e){return e.m&&e.m()}))}};const X="whist-scoreboard",Y=1,Z={numTables:15,numGames:20,scoreRows:[[0]]};function ee(){try{const e=window.localStorage.getItem("whist-scoreboard");if(null==e)return Z;const t=JSON.parse(e);if(t.version!==Y)throw new Error(`Unsupported version in local storage: ${t.version}`);let{numTables:n,numGames:o,scoreRows:r}=t;return("number"!=typeof n||n<1||n>100)&&(n=Z.numTables),("number"!=typeof o||o<1||o>100)&&(o=Z.numGames),Array.isArray(r)||(r=Z.scoreRows),{numTables:n,numGames:o,scoreRows:r}}catch(e){console.error(e);try{window.localStorage.removeItem(X)}catch(e){}return Z}}M(p((function(){const e=W(ee,[]),[t,n]=L(e.numTables),[o,r]=L(e.numGames),[l,u]=L(e.scoreRows);function i(){setTimeout((function(){window.scrollTo(document.body.scrollWidth,document.body.scrollTop)}),0)}function c(e,t,n){let o=Array.from(l);o[e]=Array.from(o[e]||[]),o[e][t]=n(o[e][t]||0),u(o)}!function(e,t){var n=F(D++);V(n.o,t)&&(n.i=e,n.o=t,O.__H.u.push(n))}(()=>{!function(e){try{const t=Object.assign({version:Y},e);window.localStorage.setItem(X,JSON.stringify(t))}catch(e){console.error(e);try{window.localStorage.removeItem(X)}catch(e){}}}({numTables:t,numGames:o,scoreRows:l})},[t,o,l]);const s={onOpen:K(()=>{window.alert("Sorry, loading from file is not implemented yet.")},[]),onSave:K(()=>{window.alert("Sorry, saving to file is not implemented yet.")},[]),onClear:K(e=>{window.confirm("Do you really want to erase all scores?")&&u([]),e.target&&e.target.blur()},[u]),onAddGame:K(()=>{r(Math.min(o+1,100)),i()},[o,r]),onRemoveGame:K(()=>{r(Math.max(o-1,1)),i()},[o,r]),onSetTables:K(e=>{const t=parseInt(e,10);isNaN(t)||n(Math.min(Math.max(t,1),100))},[t,n]),onSetGames:K(e=>{const t=parseInt(e,10);isNaN(t)||(r(Math.min(Math.max(t,1),100)),i())},[o,r])};function a(e){let t=e.target;for(;t;t=t.parentNode)if(t.id){let e;if(null!=(e=/^score-(\d+)-(\d+)$/.exec(t.id)))return[parseInt(e[1]),parseInt(e[2])];if(null!=(e=/^game-(\d+)$/.exec(t.id)))return[-1,parseInt(e[1])]}return[-1,-1]}function _(e,t){const n=document.querySelector(`#score-${e}-${t} button`);n&&n.focus()}return p("table",{onClick:function(e){const[t,n]=a(e);t>=0?(e.preventDefault(),c(t,n,e=>(e+1)%5)):n>=0&&(e.preventDefault(),_(0,n))},onKeydown:function(e){const[t,n]=a(e);if(!(t<0||n<0||e.altKey||e.ctrlKey||e.metaKey||e.shiftKey)){switch(e.key){case"ArrowLeft":_(t,n-1);break;case"ArrowRight":_(t,n+1);break;case"ArrowUp":_(t-1,n);break;case"ArrowDown":_(t+1,n);break;case"Escape":const o=document.activeElement;null!=o&&o.blur();break;case"0":case"1":case"2":case"3":case"4":c(t,n,()=>parseInt(e.key));break;default:return}e.preventDefault()}}},[p("col",{class:"col-table"}),p("colgroup",{},Array.from({length:o},()=>p("col",{class:"col-game"}))),p("col",{class:"col-stretch"}),p("col",{class:"col-total"}),p("thead",{},[p(Q,Object.assign({numTables:t,numGames:o},s))]),Array.from({length:t},(e,t)=>p("tr",{class:"score"},function({row:e,numGames:t,scores:n}){n||(n=[]);let o=0;for(let e=0;e<t;e++)o+=n[e]||0;return[p("th",{class:"table",scope:"row"},`${e+1}`),Array.from({length:t},(t,o)=>{const r=n[o]||0;return p("td",{class:"score",id:`score-${e}-${o}`},[p("button",{},[r>0&&p("img",{src:`tally-${r}.svg`})])])}),p("td",{class:"col-stretch"}),p("td",{class:"total"},o)]}({row:t,numGames:o,scores:l[t]})))])}),{}),document.getElementById("app"))}]);