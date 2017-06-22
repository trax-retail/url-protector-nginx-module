# URL Protector

This module allow nginx to decrypt strings encrypted with [xxtea](https://en.wikipedia.org/wiki/XXTEA) algorithm.

## Installation

1. `git clone git@bitbucket.org:traxtechnology/url-protector-nginx-module.git`
2. `git submodule update --init --recursive`
3. `./build.sh`

## Usage

Load modules in `nginx.conf`:

```
load_module /path/to/modules/ndk_http_module.so;
load_module /path/to/modules/ngx_http_url_protector_module.so;
```

In server config:

```
location = /test {
    set_decryption_key 1234567890;
    set_decrypt_url $arg_decrypted_url $arg_url;
    proxy_pass $arg_decrypted_url;
}
```

## Encryption Example

```javascript
const xxtea = require('xxtea-node');

const url = 'https://en.wikipedia.org/wiki/XXTEA';
const key = '1234567890';
const encryptedData = xxtea.encrypt(xxtea.toBytes(str), xxtea.toBytes(key));
const encryptedStr = new Buffer(encryptedData).toString('base64');

console.log(`http://localhost:80/test?url=${encryptedStr}`);
````

__Note:__

- We use [xxtea-node](https://www.npmjs.com/package/xxtea-node) npm package in this example.
- Decryption key length should be not less what average URL size.
- If your URLs are predictable, add random part to avoid [chosen-plaintext attack](https://en.wikipedia.org/wiki/Chosen-plaintext_attack).

## Dependencies

- [Nginx Development Kit](https://github.com/simpl/ngx_devel_kit)
- [XXTEA for C](https://github.com/xxtea/xxtea-c)
