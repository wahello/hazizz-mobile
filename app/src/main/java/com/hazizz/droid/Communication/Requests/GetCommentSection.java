package com.hazizz.droid.Communication.Requests;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.google.gson.reflect.TypeToken;
import com.hazizz.droid.Communication.POJO.Response.CommentSectionPOJOs.POJOComment;
import com.hazizz.droid.Communication.POJO.Response.CustomResponseHandler;
import com.hazizz.droid.Communication.Strings;
import com.hazizz.droid.SharedPrefs;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import okhttp3.ResponseBody;
import retrofit2.Response;

public class GetCommentSection extends Request {
    String p_whereName,p_whereId;
    public GetCommentSection(Activity act, CustomResponseHandler rh, String whereName, int whereId) {
        super(act, rh);
        Log.e("hey", "created GetCommentSection object");
        this.p_whereName = whereName.toString();
        this.p_whereId = Integer.toString(whereId);
    }

    /*
    public GetCommentSection(Activity act, CustomResponseHandler rh, String whereName, int whereId, String byName, int byId) {
        super(act, rh);
        Log.e("hey", "created GetMyProfilePic object");
        this.p_whereName = whereName;
        this.p_whereId = Integer.toString(whereId);
        this.p_byName = byName;
        this.p_byId = Integer.toString(byId);
    }
    */

    public void setupCall() {
        HashMap<String, String> headerMap = new HashMap<String, String>();
        headerMap.put("Authorization", "Bearer " + SharedPrefs.TokenManager.getToken(act.getBaseContext()));

        call = aRequest.getCommentSection(p_whereName, p_whereId, headerMap);
    }

    @Override
    public void makeCall() {
        call(act,  thisRequest, call, cOnResponse, gson);
    }

    @Override
    public void makeCallAgain() {
        callAgain(act,  thisRequest, call, cOnResponse, gson);
    }

    @Override
    public void callIsSuccessful(Response<ResponseBody> response) {
        Type listType = new TypeToken<ArrayList<POJOComment>>(){}.getType();
        List<POJOComment> castedList = gson.fromJson(response.body().charStream(), listType);

        cOnResponse.onPOJOResponse(castedList);
    }
}