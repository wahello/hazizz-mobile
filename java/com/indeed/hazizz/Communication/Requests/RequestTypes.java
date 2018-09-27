package com.indeed.hazizz.Communication.Requests;

import com.indeed.hazizz.Communication.POJO.Response.POJOcreateTask;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Communication.POJO.Response.POJOgroup;
import com.indeed.hazizz.Communication.POJO.Response.POJOme;
import com.indeed.hazizz.Communication.POJO.Response.POJOregister;
import com.indeed.hazizz.Communication.POJO.Response.POJOsubjects;

import org.json.JSONObject;


import java.util.HashMap;
import java.util.Map;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.HeaderMap;
import retrofit2.http.*;

public interface RequestTypes{

    @POST("register")
    Call<POJOregister> register(
            @HeaderMap Map<String, String> headers,
            @Body HashMap<String, Object>  register
    );

    @GET("users/")
    Call<HashMap<String, Object>> getUsers(
            @HeaderMap Map<String, String> headers,
            @Body JSONObject registerBody
    );

    @POST("auth/")
    Call<HashMap<String, Object>> login(
            @HeaderMap Map<String, String> headers,
            @Body HashMap<String, Object> registerBody
    );

    @GET("me/details")
    Call<POJOme> me(
            @HeaderMap Map<String, String> headers
    );

    // Groups

    @GET("groups/{id}")
    Call<POJOgroup> getGroup(
            @Path("id") String id,
            @HeaderMap Map<String, String> headers
    );

    @POST("groups/2/tasks")
    Call<POJOerror> createTask(
          //  @Path("id") String id,
            @HeaderMap Map<String, String> headers,
            @Body HashMap<String, Object> taskBody
    );

    @GET("groups/{id}/subjectsasd")
    Call<ResponseBody> getSubjects(
            @Path("id") String id,
            @HeaderMap Map<String, String> headers
    );
}
