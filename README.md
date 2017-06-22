# URL Protector

This module allow [nginx](https://www.nginx.com/) to decrypt strings encrypted with [xxtea](https://en.wikipedia.org/wiki/XXTEA) algorithm.

## Installation

```bash
git clone git@bitbucket.org:traxtechnology/url-protector-nginx-module.git
git submodule update --init --recursive
sudo apt-get install build-essential zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev
sudo ./install.sh
```
__Note:__ you can use custom nginx configuration, just copy and modify `install.sh` as you wish.

## Usage

Load modules in `nginx.conf`:

```
load_module /usr/lib/nginx/modules/ndk_http_module.so;
load_module /usr/lib/nginx/modules/ngx_http_url_protector_module.so;
```

Add to server config:

```
location = /test {
    set_decryption_key 1234567890;
    set_decrypted_str $arg_decrypted_url $arg_url;
    resolver 8.8.8.8;
    proxy_pass $arg_decrypted_url;
}
```

__Note:__ 

- Path `/usr/lib/nginx/modules/` may be different in your system.
- Usually, path to your `nginx.conf` is `/etc/nginx/nginx.conf`.
- Use your own resolver to avoid [DNS spoofing attack](http://blog.zorinaq.com/nginx-resolver-vulns/#attack-scenarios). Use `nm-tool | grep DNS` to determine which one you use.

## Encryption Example

```javascript
const xxtea = require('xxtea-node');

const url = 'https://en.wikipedia.org/wiki/XXTEA';
const key = '1234567890';
const encryptedData = xxtea.encrypt(xxtea.toBytes(url), xxtea.toBytes(key));
const encryptedStr = new Buffer(encryptedData).toString('base64');

console.log(`http://localhost/test?url=${encryptedStr}`);
// http://localhost/test?url=Xhy4HUCNVpWRG4dDN1KS9Y8mrHoz6IhJBirn2qcDtl9lBGz6OiFwgA==
```

__Note:__

- We use [xxtea-node](https://www.npmjs.com/package/xxtea-node) npm package in this example.
- Decryption key length should be not less what average URL size.
- If your URLs are predictable, add random part to avoid [chosen-plaintext attack](https://en.wikipedia.org/wiki/Chosen-plaintext_attack).

## Dependencies

- [nginx](https://www.nginx.com/) version 1.11.5 or greater.
- [Nginx Development Kit](https://github.com/simpl/ngx_devel_kit)
- [XXTEA for C](https://github.com/xxtea/xxtea-c)
