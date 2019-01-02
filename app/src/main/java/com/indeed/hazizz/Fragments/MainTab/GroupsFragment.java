package com.indeed.hazizz.Fragments.MainTab;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.indeed.hazizz.Activities.MainActivity;
import com.indeed.hazizz.Communication.MiddleMan;
import com.indeed.hazizz.Communication.POJO.Response.CustomResponseHandler;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Communication.POJO.Response.POJOgroup;
import com.indeed.hazizz.Listviews.GroupList.CustomAdapter;
import com.indeed.hazizz.Listviews.GroupList.GroupItem;
import com.indeed.hazizz.Manager;
import com.indeed.hazizz.R;
import com.indeed.hazizz.Transactor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import okhttp3.Headers;
import okhttp3.ResponseBody;
import retrofit2.Call;

public class GroupsFragment extends Fragment {

    public List<POJOgroup> groups;
    private List<GroupItem> listGroup;
    private View v;
    private CustomAdapter adapter;
    private TextView textView_noContent;
    private TextView textView_title;

    private String dest;

    private SwipeRefreshLayout sRefreshLayout;


    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.fragment_group, container, false);
        ((MainActivity)getActivity()).onFragmentCreated();
        groups = new ArrayList<POJOgroup>();

        createViewList();
        textView_noContent = v.findViewById(R.id.textView_noContent);
        textView_title = v.findViewById(R.id.textView_title);
        sRefreshLayout = v.findViewById(R.id.swipe_refresh_layout); sRefreshLayout.bringToFront();
        sRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                getGroups();
            }});

        getGroups();


        return v;
    }

    public void getGroups() {
        Log.e("hey", "atleast here 2");
        adapter.clear();
        CustomResponseHandler responseHandler = new CustomResponseHandler() {
            @Override
            public void onResponse(HashMap<String, Object> response) { }
            @Override
            public void onPOJOResponse(Object response) {
                textView_noContent.setVisibility(v.INVISIBLE);
                ArrayList<POJOgroup> castedListFullOfPojos = (ArrayList<POJOgroup>)response;
                listGroup.clear();
                if(castedListFullOfPojos.size() != 0) {
                    for (POJOgroup g : castedListFullOfPojos) {
                        listGroup.add(new GroupItem(R.drawable.ic_launcher_background, g.getName(), g.getId()));
                    }

                    adapter.notifyDataSetChanged();
                }else{
                    textView_noContent.setText(R.string.error_notMemberOfGroup);
                }
                sRefreshLayout.setRefreshing(false);
                Log.e("hey", "got response");
            }
            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Log.e("hey", "4");
                Log.e("hey", "got here onFailure");
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onErrorResponse(POJOerror error) {
                Log.e("hey", "onErrorResponse");
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onEmptyResponse() {
                textView_noContent.setVisibility(v.VISIBLE);
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onSuccessfulResponse() { }
            @Override
            public void onNoConnection() {
                textView_noContent.setText(R.string.info_noInternetAccess);
                textView_noContent.setVisibility(View.VISIBLE);
                sRefreshLayout.setRefreshing(false);
            }

            @Override
            public void getHeaders(Headers headers) {

            }
        };
        MiddleMan.newRequest(this.getActivity(),"getGroupsFromMe", null, responseHandler, null);
    }

    void createViewList(){
        listGroup = new ArrayList<>();

        ListView listView = (ListView)v.findViewById(R.id.listView1);

        adapter = new CustomAdapter(getActivity(), R.layout.list_item, listGroup);
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                switch (Manager.DestManager.getDest()) {
                    case Manager.DestManager.TOCREATETASK:
                        Manager.GroupManager.setGroupId(((GroupItem) listView.getItemAtPosition(i)).getGroupId());
                        Manager.GroupManager.setGroupName(((GroupItem) listView.getItemAtPosition(i)).getGroupName());
                        Transactor.fragmentCreateTask(getFragmentManager().beginTransaction(), ((GroupItem) listView.getItemAtPosition(i)).getGroupId(), ((GroupItem) listView.getItemAtPosition(i)).getGroupName(), Manager.DestManager.TOMAIN);
                        break;
                    case Manager.DestManager.TOCREATEANNOUNCEMENT:
                        Manager.GroupManager.setGroupId(((GroupItem) listView.getItemAtPosition(i)).getGroupId());
                        Manager.GroupManager.setGroupName(((GroupItem) listView.getItemAtPosition(i)).getGroupName());
                        Transactor.fragmentCreateAnnouncement(getFragmentManager().beginTransaction(), ((GroupItem) listView.getItemAtPosition(i)).getGroupId(), ((GroupItem) listView.getItemAtPosition(i)).getGroupName(), Manager.DestManager.TOMAIN);
                        break;
                    case Manager.DestManager.TOMAIN:
                        Transactor.fragmentMainGroup(getFragmentManager().beginTransaction(), ((GroupItem) listView.getItemAtPosition(i)).getGroupId(), ((GroupItem) listView.getItemAtPosition(i)).getGroupName());
                        break;
                    default:
                        Transactor.fragmentMainGroup(getFragmentManager().beginTransaction(), ((GroupItem) listView.getItemAtPosition(i)).getGroupId(), ((GroupItem) listView.getItemAtPosition(i)).getGroupName());
                        break;
                }
            }
        });
    }

    public void toJoinGroup(){
        Transactor.fragmentCreateGroup(getFragmentManager().beginTransaction());
    }

    public void toCreateGroup(FragmentManager fm){
        Transactor.fragmentCreateGroup(fm.beginTransaction());
    }
}
