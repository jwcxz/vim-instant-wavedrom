(function () {
    function ssvg () {
        var svg, ser;

        svg = document.getElementById('svgcontent_0');
        ser = new XMLSerializer();
        return '<?xml version="1.0" standalone="no"?>\n'
            + '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n'
            + '<!-- Created with WaveDrom -->\n'
            + ser.serializeToString(svg);
    }

    function saveSVG () {
        var a;

        function chooseFile(name) {
            var chooser = document.querySelector(name);

            chooser.addEventListener('change', function() {
                var fs = require('fs');
                var filename = this.value;
                if (!filename) { return; }
                fs.writeFile(filename, ssvg(), function(err) {
                    if(err) {
                        console.log('error');
                    }
                });
                this.value = '';
            }, false);
            chooser.click();
        }

        if (typeof process === 'object') { // nodewebkit detection
            chooseFile('#fileDialogSVG');
        } else {
            a = document.createElement('a');
            a.href = 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(ssvg())));
            a.download = 'wavedrom.svg';
            var theEvent = document.createEvent('MouseEvent');
            theEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(theEvent);
            // a.click();
        }
    }

    function pngdata (done) {

        var img = new Image();
        var canvas = document.createElement('canvas');

        function onload () {
            canvas.width = img.width;
            canvas.height = img.height;
            var context = canvas.getContext('2d');
            context.drawImage(img, 0, 0);
            var res = canvas.toDataURL('image/png');
            done(res);
        }

        var svgBody = ssvg();
        var svgdata = 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(svgBody)));
        img.src = svgdata;

        if (img.complete) {
            onload();
        } else {
            img.onload = onload;
        }
    }

    function savePNG () {
        var a;

        function chooseFile(name) {
            var chooser = document.querySelector(name);

            chooser.addEventListener('change', function() {
                var fs = require('fs');
                var filename = this.value;
                if (!filename) { return; }
                pngdata(function (data) {
                    data = data.replace(/^data:image\/\w+;base64,/, '');
                    var buf = new Buffer(data, 'base64');
                    fs.writeFile(filename, buf, function(err) {
                        if (err) {
                            console.log('error');
                        }
                    });
                    this.value = '';
                });
            }, false);
            chooser.click();
        }

        if (typeof process === 'object') { // nodewebkit detection
            chooseFile('#fileDialogPNG');
        } else {
            a = document.createElement('a');
            pngdata(function (res) {
                a.href = res;
                a.download = 'wavedrom.png';
                var theEvent = document.createEvent('MouseEvent');
                theEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                a.dispatchEvent(theEvent);
                // a.click();
            });
        }
    }

    WaveDrom.saveSVG = saveSVG;
    WaveDrom.savePNG = savePNG;
})();
