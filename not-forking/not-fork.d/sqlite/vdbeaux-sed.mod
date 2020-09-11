# this is an example, it is not the modifications we will be making
# to vdbeaux.c -- but it's here to test the not-fork tool

method = sed
--
vdbeaux.c : sqlite3BtreeGetJournalname = BackendGetJournal

