## 0.0.4

- Fix Mail body parser bug, the previous version will lose the content after the newline.
- Body parse don't covert chars, to fix Chinese charset encoding bug.
- Fix the encoding error, some mail receive content encoding not UTF-8, force convert it.

## 0.0.3

- Fixed the MergeRequest can't create Note with reply email bug, missing the `t` field in the `reply_to` address.

## 0.0.2

- Add Daemon feature.
- Change Reply email address to QueryString style, for example: `foo+p=foo/bar&id=123&n=43&t=m@gitlab.com`;
- Add Reply target support, this will fix relationship of the replies;
- Add test case;

## 0.0.1

First release.
