IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKING.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT IN-FILE ASSIGN TO "input.txt".
           SELECT ACC-FILE ASSIGN TO "accounts.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TMP-FILE ASSIGN TO "temp.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT OUT-FILE ASSIGN TO "output.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD IN-FILE.
       01 IN-RECORD             PIC X(18).

       FD ACC-FILE.
       01 ACC-RECORD-RAW        PIC X(18).

       FD TMP-FILE.
       01 TMP-RECORD            PIC X(18).

       FD OUT-FILE.
       01 OUT-RECORD            PIC X(80).

       WORKING-STORAGE SECTION.
       77 IN-ACCOUNT            PIC 9(6).
       77 IN-ACTION             PIC X(3).
       77 IN-AMOUNT             PIC 9(7)V99.
       77 ACC-ACCOUNT           PIC 9(6).
       77 ACC-BALANCE           PIC 9(7)V99.
       77 TMP-BALANCE           PIC 9(7)V99.
       77 MATCH-FOUND           PIC X VALUE "N".
       77 UPDATED               PIC X VALUE "N".
       77 FORMATTED-BALANCE     PIC Z(7).99.

       77 RUPIAH-RATE          PIC 9(9) VALUE 120000000.
       77 RUPIAH-BALANCE       PIC 9(16)V99.
       77 FORMATTED-RUPIAH     PIC Z(16).99.
      
       01 FORMATTED-REC-OUT.
           05 REC-ACCOUNT       PIC 9(6).
           05 REC-ACTION        PIC X(3) VALUE "BAL".
           05 REC-BALANCE       PIC 9(7).99.

       PROCEDURE DIVISION.

       MAIN.
           INITIALIZE OUT-RECORD.
           PERFORM READ-INPUT.
           PERFORM PROCESS-RECORDS.
           IF MATCH-FOUND = "N"
               IF IN-ACTION = "NEW"
                   PERFORM APPEND-ACCOUNT
               ELSE
                   MOVE "ERROR: ACCOUNT NOT FOUND" TO OUT-RECORD
               END-IF
           END-IF.
           PERFORM FINALIZE.
           STOP RUN.

       READ-INPUT.
           OPEN INPUT IN-FILE.
           READ IN-FILE AT END
               DISPLAY "NO INPUT"
               STOP RUN
           END-READ.
           CLOSE IN-FILE.

           MOVE IN-RECORD(1:6) TO IN-ACCOUNT.
           MOVE IN-RECORD(7:3) TO IN-ACTION.
           MOVE FUNCTION NUMVAL(IN-RECORD(10:9)) TO IN-AMOUNT.

       PROCESS-RECORDS.
           OPEN INPUT ACC-FILE.
           OPEN OUTPUT TMP-FILE.
           PERFORM UNTIL 1 = 2
               READ ACC-FILE
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       MOVE ACC-RECORD-RAW(1:6) TO ACC-ACCOUNT
                       MOVE FUNCTION NUMVAL(ACC-RECORD-RAW(10:9))
                           TO ACC-BALANCE
                       IF ACC-ACCOUNT = IN-ACCOUNT
                           MOVE "Y" TO MATCH-FOUND
                           PERFORM APPLY-ACTION
                       ELSE
                           WRITE TMP-RECORD FROM ACC-RECORD-RAW
                       END-IF
           END-PERFORM.
           CLOSE ACC-FILE.
           CLOSE TMP-FILE.

       APPLY-ACTION.
           MOVE ACC-BALANCE TO TMP-BALANCE.
           EVALUATE IN-ACTION
               WHEN "NEW"
                   MOVE "ERROR: ACCOUNT ALREADY EXISTS" TO OUT-RECORD
                   WRITE TMP-RECORD FROM ACC-RECORD-RAW
               WHEN "DEP"
                   ADD IN-AMOUNT TO TMP-BALANCE
                   MOVE "SUCCESS: DEPOSIT COMPLETE" TO OUT-RECORD
                   PERFORM WRITE-UPDATED-RECORD
               WHEN "WDR"
                   IF TMP-BALANCE >= IN-AMOUNT
                       SUBTRACT IN-AMOUNT FROM TMP-BALANCE
                       MOVE "SUCCESS: WITHDRAWAL COMPLETE" TO OUT-RECORD
                       PERFORM WRITE-UPDATED-RECORD
                   ELSE
                       MOVE "ERROR: INSUFFICIENT FUNDS" TO OUT-RECORD
                       WRITE TMP-RECORD FROM ACC-RECORD-RAW
                   END-IF
               WHEN "BAL"
                   COMPUTE RUPIAH-BALANCE = TMP-BALANCE * RUPIAH-RATE
                   MOVE RUPIAH-BALANCE TO FORMATTED-RUPIAH
                   STRING "SUCCESS: BALANCE IS Rp "
                          FUNCTION TRIM(FORMATTED-RUPIAH)
                          INTO OUT-RECORD
                   WRITE TMP-RECORD FROM ACC-RECORD-RAW
               WHEN OTHER
                   MOVE "ERROR: UNKNOWN ACTION" TO OUT-RECORD
                   WRITE TMP-RECORD FROM ACC-RECORD-RAW
           END-EVALUATE.

       WRITE-UPDATED-RECORD.
           MOVE IN-ACCOUNT TO REC-ACCOUNT.
           MOVE TMP-BALANCE TO REC-BALANCE.
           WRITE TMP-RECORD FROM FORMATTED-REC-OUT.
           MOVE "Y" TO UPDATED.

       APPEND-ACCOUNT.
           OPEN EXTEND ACC-FILE.
           MOVE IN-ACCOUNT TO REC-ACCOUNT.
           MOVE IN-AMOUNT TO REC-BALANCE.
           WRITE ACC-RECORD-RAW FROM FORMATTED-REC-OUT.
           CLOSE ACC-FILE.
           MOVE "SUCCESS: ACCOUNT CREATED" TO OUT-RECORD.

       FINALIZE.
           IF UPDATED = "Y"
               CALL "SYSTEM" USING "mv temp.txt accounts.txt"
           END-IF.
           OPEN OUTPUT OUT-FILE.
           WRITE OUT-RECORD.
           CLOSE OUT-FILE.