Use Windows.pkg
Use DFClient.pkg
Use cTextEdit.pkg
Use cJsonObject.pkg
Use cCJGrid.pkg
Use cCJGridColumnRowIndicator.pkg
Use cCJGridColumn.pkg
Use cChatGPTAPI.pkg

Deferred_View Activate_oChatGPTTest for ;
Object oChatGPTTest is a dbView
    
    Property String   psChatGPTBasePath "v1/"
    
    Property String[] pasSpeakers
    Property String[] pasMessages
    Property String[] pasTimes
    
    Set Border_Style to Border_Thick
    Set Size to 340 628
    Set Location to 2 2
    Set Label to "ChatGPT Test View"
    
    Object oChatGPT is a cChatGPTAPI
    End_Object
    
    Procedure AddToHistory String sSpeaker String sMsg
        String[]   asSpeakers asMsgs asTimes
        
        Get pasSpeakers to asSpeakers
        Get pasMessages to asMsgs
        Get pasTimes    to asTimes
        
        Move sSpeaker               to asSpeakers[-1]
        Move sMsg                   to asMsgs[-1]
        Move (CurrentDateTime())    to asTimes[-1]
        
        Set pasSpeakers to asSpeakers
        Set pasMessages to asMsgs
        Set pasTimes    to asTimes
        
        Send ReloadHist of oHistory
    End_Procedure
    
    Procedure AskChatGPT
        String sAsk sResp sModel
        
        Send Cursor_Wait of oCursor
        Get Value of oAsk       to sAsk
        Get Value of oModels    to sModel
        
        Send AddToHistory "You" sAsk
        
        Get Ask of oChatGPT sAsk sModel to sResp
        
        If (sResp <> "") Begin
            Set Value of oResponse to sResp
            Send AddToHistory "ChatGPT" sResp
        End
        Else Begin
            Send AddToHistory "ChatGPT" "No response received"
            Send Info_Box ("ChatGPT did not respond - there was probably a timeout. 🙁" + ;
                           "\nPerhaps just try sending your question again") "ChatGPT Error"
        End
        
        Send Cursor_Ready of oCursor
    End_Procedure
    
    Object oModels is a ComboForm
        Set Size to 12 100
        Set Location to 4 521
        Set Label to "ChatGPT Model to use:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set peAnchors to anTopRight
    
        Procedure Combo_Fill_List
            Integer  i iMax
            String[] asMods
            
            Get AvailableModels of oChatGPT to asMods
            Move (SizeOfArray(asMods) - 1)  to iMax
            
            For i from 0 to iMax
                Send Combo_Add_Item asMods[i]
            Loop
            
            Set Value to "gpt-3.5-turbo"
        End_Procedure
      
    End_Object

    Object oAsk is a cTextEdit
        Set Size to 36 554
        Set Location to 28 10
        Set Label to "Ask ChatGPT something:"
        Set peAnchors to anTopLeftRight
    End_Object

    Object oSendBtn is a Button
        Set Location to 28 571
        Set Label to "Send"
        Set peAnchors to anTopRight
    
        Procedure OnClick
            Send AskChatGPT
        End_Procedure
    
    End_Object

    Object oClearBtn is a Button
        Set Location to 46 571
        Set Label to "Clear"
        Set peAnchors to anTopRight
    
        Procedure OnClick
            Set Value of oAsk to ""
        End_Procedure
    
    End_Object

    Object oResponse is a cTextEdit
        Set Size to 128 610
        Set Location to 77 10
        Set Label to "ChatGPT replied:"
        Set peAnchors to anAll
    End_Object

    Object oHistText is a TextBox
        Set Size to 9 25
        Set Location to 210 10
        Set Label to "History:"
        Set peAnchors to anBottomLeft
    End_Object

    Object oHistory is a cCJGrid
        Set Size to 65 611
        Set Location to 220 10
        Set peAnchors to anBottomLeftRight
        Set pbReadOnly to True

        Object oCJGridColumnRowIndicator1 is a cCJGridColumnRowIndicator
        End_Object

        Object oDateTime is a cCJGridColumn
            Set piWidth to 50
            Set psCaption to "Time"
        End_Object
        
        Object oSpeaker is a cCJGridColumn
            Set piWidth to 20
            Set psCaption to "Speaker"
        End_Object

        Object oMessage is a cCJGridColumn
            Set piWidth to 350
            Set psCaption to "Message"
        End_Object

        Procedure ReloadHist
            tDataSourceRow[] atRows
            Integer    iSpkCol iMsgCol iTimeCol i iMax
            String[]   asSpeakers asMsgs asTimes
            
            Get pasSpeakers to asSpeakers
            Get pasMessages to asMsgs
            Get pasTimes    to asTimes
            
            Get piColumnID of oSpeaker  to iSpkCol
            Get piColumnID of oMessage  to iMsgCol
            Get piColumnID of oDateTime to iTimeCol
            
            Move (SizeOfArray(asSpeakers) - 1) to iMax
            
            For i from 0 to iMax
                Move asTimes[iMax - i]    to atRows[i].sValue[iTimeCol]
                Move asSpeakers[iMax - i] to atRows[i].sValue[iSpkCol]
                Move asMsgs[iMax - i]     to atRows[i].sValue[iMsgCol]
            Loop
            
            Send InitializeData atRows
            Send MoveToFirstRow    
        End_Procedure
        
        Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
            String[] asSpeakers asMsgs asTimes
            Integer  iMax i
            
            Get pasSpeakers to asSpeakers
            Get pasMessages to asMsgs
            Get pasTimes    to asTimes
            Move (SizeOfArray(asSpeakers) - 1) to iMax
            Move (iMax - iNewSelectedRow) to i
            
            Set Value of oMsgContent to (Trim(asSpeakers[i]) * ;
                                        "(at" * Trim(asTimes[i] + "):" * ;
                                        Trim(asMsgs[i])))
        End_Procedure
        
    End_Object

    Object oMsgText is a TextBox
        Set Size to 9 29
        Set Location to 287 10
        Set Label to "Message:"
        Set peAnchors to anBottomLeft
    End_Object

    Object oMsgContent is a cTextEdit
        Set Size to 40 611
        Set Location to 297 10
        Set peAnchors to anBottomLeftRight
    End_Object

Cd_End_Object
