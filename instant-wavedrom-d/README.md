!nstant-wavedrom-d
==================

instant-wavedrom-d is a small Node.js server that enables rendering of
[WaveDrom](https://wavedrom.com) files.

It is based entirely off of [suan](https://github.com/suan)'s excellent
[instant-markdown-d](https://github.com/suan/instant-markdown-d), with only
minor tweaks to render WaveDrom instead of Markdown.


REST API
--------

| Action           | HTTP Method | Request URL               | Request Body |
|---------------------|-------------|---------------------------|--------------------|
| Refresh Markdown on page | PUT        | http://localhost:\<port\> | \<New Markdown file contents\> |
| Close Webpage    | DELETE      | http://localhost:\<port\> | |

By default, `<port>` is 8091
