# rewritten bypasses for fun
# internal bypass tweak
медный бык 14888
## TODO

- [ ] Починить хук `appStoreReceiptURL` в bundle.xm.  
      Подробности смотреть [здесь](https://github.com/andrd3v/so2/blob/main/bundle.xm#L536)

- [ ] починить, у обычной прилы не должно быть сдхэша
```
/*
        if(ops == CS_OPS_CDHASH)
        {
            // Hide CDHASH for trustcache checks
            errno = EBADEXEC;
            return -1;
        }*/
```
