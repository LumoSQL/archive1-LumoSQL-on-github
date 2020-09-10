# this is an example, it is not the modifications we will be making
# to vdbeaux.c -- but it's here to test the not-fork tool

method = patch
--
--- sqlite-git/src/vdbeaux.c    2020-02-17 19:53:07.030886721 +0100
+++ new/src/vdbeaux.c      2020-03-21 13:52:24.861586555 +0100
@@ -2738,7 +2738,7 @@
     for(i=0; i<db->nDb; i++){
       Btree *pBt = db->aDb[i].pBt;
       if( sqlite3BtreeIsInTrans(pBt) ){
-        char const *zFile = sqlite3BtreeGetJournalname(pBt);
+        char const *zFile = BackendGetJournal(pBt);
         if( zFile==0 ){
           continue;  /* Ignore TEMP and :memory: databases */
         }
