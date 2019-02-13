package com.hazizz.droid.Communication.Requests.MyTask;

import android.app.Activity;
import android.util.Log;

import com.hazizz.droid.Communication.POJO.Response.CustomResponseHandler;
import com.hazizz.droid.Communication.Requests.Request;
import com.hazizz.droid.SharedPrefs;

import java.util.HashMap;

import okhttp3.ResponseBody;
import retrofit2.Response;

public class EditMyTask extends Request {
    String p_taskId;
    public EditMyTask(Activity act, CustomResponseHandler rh, int p_taskId,
                  int b_taskType, String b_taskTitle, String b_description, String b_dueDate) {
        super(act, rh);
        Log.e("hey", "created EditMyTask object");
        this.p_taskId = Integer.toString(p_taskId);
        body.put("taskType", b_taskType);
        body.put("taskTitle", b_taskTitle);
        body.put("description", b_description);
        body.put("dueDate", b_dueDate);
    }
    @Override public void makeCall() {
        call(act,  thisRequest, call, cOnResponse, gson);
    }
    @Override public void makeCallAgain() {
        callAgain(act,  thisRequest, call, cOnResponse, gson);
    }
    public void setupCall() {
        HashMap<String, String> headerMap = new HashMap<>();
        headerMap.put("Content-Type", "application/json");
        headerMap.put("Authorization", "Bearer " + SharedPrefs.TokenManager.getToken(act.getBaseContext()));
        call = aRequest.updateMyTask(p_taskId, body, headerMap);
    }
    @Override public void callIsSuccessful(Response<ResponseBody> response) {
        cOnResponse.onSuccessfulResponse();
    }
}