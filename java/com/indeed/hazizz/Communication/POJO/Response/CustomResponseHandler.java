package com.indeed.hazizz.Communication.POJO.Response;

import java.util.HashMap;

public interface CustomResponseHandler {

    public void onResponse(HashMap<String, Object> response);
    public void onPOJOResponse(Object response);
    public void onFailure();
    public void onErrorResponse(HashMap<String, Object> response);

}