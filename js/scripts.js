// DB
function _getDB() {
    return LocalStorage.openDatabaseSync("UPocket", "1.0", "Ubuntu Pocket app database", 2048)
}

function initializeUser() {
    var user = _getDB();
    user.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS user(key TEXT UNIQUE, value TEXT)');
                });
}
// This function is used to write a key into the database
function setKey(key, value) {
    var db = _getDB();
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO user VALUES (?,?);', [key,""+value]);
        if (rs.rowsAffected == 0) {
            throw "Error updating key";
        } else {
            //console.log("User record updated:"+key+" = "+value);
        }
    });
}
// This function is used to retrieve a key from the database
function getKey(key) {
    var db = _getDB();
    var returnValue = undefined;

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM user WHERE key=?;', [key]);
        if (rs.rows.length > 0)
          returnValue = rs.rows.item(0).value;
    })

    return returnValue;
}
// This function is used to delete a key from the database
function deleteKey(key) {
    var db = _getDB();

    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM user WHERE key=?;', [key]);
    })
}


function get_request_token(results) {
    if (results) {
        setKey('request_token', results['code']);
        pagestack.push(Qt.resolvedUrl("../ui/LoginPage.qml"));
    } else {
        var url = 'https://getpocket.com/v3/oauth/request';
        var data = "consumer_key="+consumer_key+"&redirect_uri=https://api.github.com/zen";

        request(url, data, get_request_token);
    }
}

function get_access_token(results) {
    if (results) {
        if (results['access_token']) {
            setKey('access_token', results['access_token']);
            setKey('username', results['username']);

            pagestack.clear();
            pagestack.push(tabs);
        }
    } else {
        var url = 'https://getpocket.com/v3/oauth/authorize';
        var data = "consumer_key="+consumer_key+"&code="+getKey('request_token');

        request(url, data, get_access_token);
    }
}

function add_item(item_url, item_title) {
    var access_token = getKey('access_token');
    var url = 'https://getpocket.com/v3/add';
    var data = "url="+item_url+"&consumer_key="+consumer_key+"&access_token="+access_token;

    request(url, data, item_added);
}

function item_added(results) {
    //console.log(JSON.stringify(results));
    if (results['item']['item_id']) {
        pagestack.clear();
        pagestack.push(tabs);
        pockethome.get_list();
    }
}

function get_list() {
    var access_token = getKey('access_token');
    var url = 'https://getpocket.com/v3/get';
    var data = "detailType=complete&consumer_key="+consumer_key+"&access_token="+access_token;

    request(url, data, list_got);
}

function list_got(results) {
    //console.log(JSON.stringify(results));
    pockethomeitemsModel.clear();
    pockethomeitems.status = 0;
    var i;
    for (i in results['list']) {
        var image = '';
        if (results['list'][i]['has_image'] == '1' && results['list'][i]['image']) {
            image = results['list'][i]['image']['src'];
        } else {
            image = '';
        }
        //results['list'][i]['resolved_title'] = results['list'][i]['resolved_title'].replace('\n', ' ');
        var only_domain = extractDomain(results['list'][i]['resolved_url']);

        var is_video = results['list'][i]['has_video'] && results['list'][i]['has_video'] != '0' ? '1' : '0';

        pockethomeitemsModel.append({"item_id":results['list'][i]['item_id'], "title":results['list'][i]['resolved_title'], "url":results['list'][i]['resolved_url'], "image":image, "domain":only_domain, "time_added":results['list'][i]['time_added'], "is_fav":results['list'][i]['favorite'], "sort_id":results['list'][i]['sort_id'], "is_video":is_video});
    }
    var n;
    var j;
    for (n=0; n < pockethomeitems.count; n++) {
        for (j=n+1; j < pockethomeitems.count; j++)
        {
            if (pockethomeitems.model.get(n).sort_id > pockethomeitems.model.get(j).sort_id)
            {
                pockethomeitems.model.move(j, n, 1);
                n=0;
            }
        }
    }

    pockethomeitems.status = 1;
}

function get_archive() {
    var access_token = getKey('access_token');
    var url = 'https://getpocket.com/v3/get';
    var data = "state=archive&detailType=complete&consumer_key="+consumer_key+"&access_token="+access_token;

    request(url, data, archive_got);
}

function archive_got(results) {
    //console.log(JSON.stringify(results));
    archivehomeitemsModel.clear();
    archivehomeitems.status = 0;
    var i;
    for (i in results['list']) {
        var image = '';
        if (results['list'][i]['has_image'] == '1' && results['list'][i]['image']) {
            image = results['list'][i]['image']['src'];
        } else {
            image = '';
        }
        //results['list'][i]['resolved_title'] = results['list'][i]['resolved_title'].replace('\n', ' ');
        var only_domain = extractDomain(results['list'][i]['resolved_url']);

        var is_video = results['list'][i]['has_video'] && results['list'][i]['has_video'] != '0' ? '1' : '0';

        archivehomeitemsModel.append({"item_id":results['list'][i]['item_id'], "title":results['list'][i]['resolved_title'], "url":results['list'][i]['resolved_url'], "image":image, "domain":only_domain, "time_added":results['list'][i]['time_added'], "is_fav":results['list'][i]['favorite'], "sort_id":results['list'][i]['sort_id'], "is_video":is_video});
    }
    var n;
    var j;
    for (n=0; n < archivehomeitems.count; n++) {
        for (j=n+1; j < archivehomeitems.count; j++)
        {
            if (archivehomeitems.model.get(n).sort_id > archivehomeitems.model.get(j).sort_id)
            {
                archivehomeitems.model.move(j, n, 1);
                n=0;
            }
        }
    }

    archivehomeitems.status = 1;
}

function get_favorites() {
    var access_token = getKey('access_token');
    var url = 'https://getpocket.com/v3/get';
    var data = "favorite=1&detailType=complete&consumer_key="+consumer_key+"&access_token="+access_token;

    request(url, data, favorites_got);
}

function favorites_got(results) {
    //console.log(JSON.stringify(results));
    favoriteshomeitemsModel.clear();
    favoriteshomeitems.status = 0;
    var i;
    for (i in results['list']) {
        var image = '';
        if (results['list'][i]['has_image'] == '1' && results['list'][i]['image']) {
            image = results['list'][i]['image']['src'];
        } else {
            image = '';
        }
        //results['list'][i]['resolved_title'] = results['list'][i]['resolved_title'].replace('\n', ' ');
        var only_domain = extractDomain(results['list'][i]['resolved_url']);

        var is_video = results['list'][i]['has_video'] && results['list'][i]['has_video'] != '0' ? '1' : '0';

        favoriteshomeitemsModel.append({"item_id":results['list'][i]['item_id'], "title":results['list'][i]['resolved_title'], "url":results['list'][i]['resolved_url'], "image":image, "domain":only_domain, "time_added":results['list'][i]['time_added'], "is_fav":results['list'][i]['favorite'], "sort_id":results['list'][i]['sort_id'], "is_video":is_video});
    }
    var n;
    var j;
    for (n=0; n < favoriteshomeitems.count; n++) {
        for (j=n+1; j < favoriteshomeitems.count; j++)
        {
            if (favoriteshomeitems.model.get(n).sort_id > favoriteshomeitems.model.get(j).sort_id)
            {
                favoriteshomeitems.model.move(j, n, 1);
                n=0;
            }
        }
    }

    favoriteshomeitems.status = 1;
}

function mod_item(item_id, action) {
    var access_token = getKey('access_token');
    var url = 'https://getpocket.com/v3/send';
    var actions = '%5B%7B%22action%22%3A%22'+action+'%22%2C%22item_id%22%3A'+item_id+'%7D%5D';

    var data = "actions="+actions+"&consumer_key="+consumer_key+"&access_token="+access_token;

    request(url, data, item_moded);
}

function item_moded(results) {
    //console.log(JSON.stringify(results));
}

function get_search(query, page) {
    var access_token = getKey('access_token');
    var url = 'https://getpocket.com/v3/get';
    if (page == 'mylist') {
        var data = "detailType=complete&search="+query+"&consumer_key="+consumer_key+"&access_token="+access_token;

        request(url, data, list_got);
    } else if (page == 'archive') {
        var data = "state=archive&detailType=complete&search="+query+"&consumer_key="+consumer_key+"&access_token="+access_token;

        request(url, data, archive_got);
    } else if (page == 'favorites') {
        var data = "favorite=1&detailType=complete&search="+query+"&consumer_key="+consumer_key+"&access_token="+access_token;

        request(url, data, favorites_got);
    }
}

function request(url, params, callback) {
    var xhr = new XMLHttpRequest;
    xhr.open("POST", url);

    var data = params;

    xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xhr.setRequestHeader("X-Accept", "application/json");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var results = JSON.parse(xhr.responseText);
            callback(results);
        }
    }

    xhr.send(data);
}

function extractDomain(url) {
    var domain;
    //find & remove protocol (http, ftp, etc.) and get domain
    if (url.indexOf("://") > -1) {
        domain = url.split('/')[2];
    }
    else {
        domain = url.split('/')[0];
    }

    //find & remove port number
    domain = domain.split(':')[0];

    return domain;
}

function objectLength(obj) {
  var result = 0;
  for(var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
    // or Object.prototype.hasOwnProperty.call(obj, prop)
      result++;
    }
  }
  return result;
}

// Article View
function parseArticleView(url) {
    articleBody.loadHtml('');
    articleView.url = '';
    articleView.ititle = ' ';

    var access_token = getKey('access_token');
    var data = "consumer_key="+consumer_key+"&url="+encodeURIComponent(url)+"&refresh=1&images=1&videos=1&output=json";

    var xhr = new XMLHttpRequest;
    xhr.open("POST", "http://text.getpocket.com/v3/text");

    xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xhr.setRequestHeader("X-Accept", "application/json");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var results = JSON.parse(xhr.responseText);

            articleView.url = url;
            articleView.ititle = results['title'] != '' ? results['title'] : ' ';
            articleView.view = 'article';

            var fSize = getKey("fontSize") ? FontUtils.sizeToPixels(getKey("fontSize")) : FontUtils.sizeToPixels('medium');
            var bColor = getKey("backgroundColor") ? getKey("backgroundColor") : "#ffffff";
            var fColor = getKey("foregroundColor") ? getKey("foregroundColor") : "#000000";
            var font = getKey("font") ? getKey("font") : "Ubuntu";

            articleBody.loadHtml(
                '<!DOCTYPE html>' +
                '<html>' +
                '<head>' +
                '<meta charset="utf-8">' +
                '<meta name="viewport" content="width=' + articleBody.width + '">' +
                '<style>' +
                'body {' +
                'background-color: ' + bColor + ';' +
                'color: ' + fColor + ';' +
                'padding: 0px ' + units.gu(1.5) + 'px;' +
                'font-family: ' + font + ';' +
                'font-size: ' + fSize + 'px;' +
                'font-weight: 100;' +
                '}' +
                'code, pre { white-space: pre-wrap; word-wrap: break-word; }' +
                'img { display: block; margin: auto; max-width: 100%; }' +
                'a { text-decoration: none; color: #00C0C0; }' +
                'span.upockit { font-size: ' + FontUtils.sizeToPixels('x-small') + 'px; color: ' + fColor + '; }' +
                'h2.upockit { font-size: ' + FontUtils.sizeToPixels('x-large') + 'px; padding-bottom: 12px; margin-bottom: 8px; border-bottom: 1px solid ' + fColor + '; }' +
                '</style>' +
                '</head>' +
                '<body>' +
                '<h2 class="upockit">' + results['title'] + '</h2>' +
                '<span class="upockit">' + results['host'] + '</span><br/>' +
                '<span class="upockit">' + results['datePublished'] + '</span><br/><br/>' +
                results['article'] +
                '</body>' +
                '</html>'
            );
        }
    }

    xhr.send(data);
}

function parsePageUrl(url) {
    articleBody.loadHtml('');
    articleView.url = '';
    articleView.ititle = ' ';
    var xhr = new XMLHttpRequest;
    xhr.open("POST", "http://fuckyeahmarkdown.com/go/");

    var data = "u="+encodeURIComponent(url)+"&read=1&preview=1&output=json";

    xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var results = JSON.parse(xhr.responseText);
            parsePageHtml(results['content'], results['title'], results['url']);
        }
    }

    xhr.send(data);
}

function parsePageHtml(content, title, url) {
    var xhr = new XMLHttpRequest;
    xhr.open("POST", "http://fuckyeahmarkdown.com/go/");

    var data = "domarkdown=1&text="+encodeURIComponent(content);

    xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            //console.log(xhr.responseText)
            articleView.url = url;
            articleView.ititle = title != '' ? title : ' ';
            articleView.view = 'article';

            var fSize = FontUtils.sizeToPixels('medium');
            var bColor = "#ffffff";
            var fColor = "#000000";

            articleBody.loadHtml(
                '<!DOCTYPE html>' +
                '<html>' +
                '<head>' +
                '<meta charset="utf-8">' +
                '<meta name="viewport" content="width=' + articleBody.width + '">' +
                '<style>' +
                'body {' +
                'background-color: ' + bColor + ';' +
                'color: ' + fColor + ';' +
                'padding: 0px ' + units.gu(1.5) + 'px;' +
                'font-family: "Ubuntu Light";' +
                'font-size: ' + fSize + 'px;' +
                'font-weight: 100;' +
                '}' +
                'code, pre { white-space: pre-wrap; word-wrap: break-word; }' +
                'img { display: block; margin: auto; max-width: 100%; }' +
                'p { text-align: justify; }' +
                'a { text-decoration: none; color: #1C2DC1; }' +
                'span.upockit { font-size: ' + FontUtils.sizeToPixels('x-small') + 'px; color: ' + UbuntuColors.darkGrey + '; }' +
                'h2.upockit { padding-bottom: 12px; margin-bottom: 8px; border-bottom: 1px solid ' + UbuntuColors.lightGrey + '; }' +
                '</style>' +
                '</head>' +
                '<body>' +
                '<h2 class="upockit">' + title + '</h2>' +
                '<span class="upockit">' + extractDomain(url) + '</span><br/><br/>' +
                xhr.responseText +
                '</body>' +
                '</html>'
            );
        }
    }

    xhr.send(data);
}
