package com.indeed.hazizz.Activities;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarDrawerToggle;
import android.util.Log;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageView;
import android.widget.TextView;

import com.indeed.hazizz.Communication.MiddleMan;
import com.indeed.hazizz.Communication.POJO.Response.CustomResponseHandler;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Communication.POJO.Response.POJOme;
import com.indeed.hazizz.Communication.POJO.Response.PojoPicSmall;
import com.indeed.hazizz.Converter.Converter;
import com.indeed.hazizz.Fragments.CreateSubjectFragment;
import com.indeed.hazizz.Fragments.GetGroupMembersFragment;
import com.indeed.hazizz.Fragments.GroupMainFragment;
import com.indeed.hazizz.Fragments.GroupTabs.GroupAnnouncementFragment;
import com.indeed.hazizz.Fragments.GroupTabs.GroupTabFragment;
import com.indeed.hazizz.Fragments.GroupsFragment;
import com.indeed.hazizz.Fragments.MainTab.MainAnnouncementFragment;
import com.indeed.hazizz.Fragments.MainTab.MainFragment;
import com.indeed.hazizz.Fragments.ViewTaskFragment;
import com.indeed.hazizz.Manager;
import com.indeed.hazizz.R;
import com.indeed.hazizz.SharedPrefs;
import com.indeed.hazizz.Transactor;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;

import okhttp3.ResponseBody;
import retrofit2.Call;

public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    private static final int PICK_PHOTO_FOR_AVATAR = 1;

    private DrawerLayout drawerLayout;
    private NavigationView navView;
    private ActionBarDrawerToggle toggle;

    private ImageView navProfilePic;
    private TextView navUsername;
    private TextView navEmail;
    private TextView navLogout;

    FloatingActionButton fab_joinGroup;
    FloatingActionButton fab_action;

    private Menu menu_options;
    private MenuItem menuItem_createGroup;
    private MenuItem menuItem_joinGroup;
    private MenuItem menuItem_leaveGroup;
    private MenuItem menuItem_profilePic;
    private MenuItem menuItem_feedback;
 //   private MenuItem menuItem_leaveGroup;

    private Menu menu_nav;

    private MenuItem menu_groups;
    private MenuItem menu_mainGroup;

    private Toolbar toolbar;
    private Fragment currentFrag;

    private Activity thisActivity = this;

    private boolean toMainFrag = false;
    CustomResponseHandler rh_profilePic = new CustomResponseHandler() {
        @Override
        public void onResponse(HashMap<String, Object> response) { }
        @Override
        public void onPOJOResponse(Object response) {
            String a = ((PojoPicSmall)response).getData().split(",")[1];
          //  String[] imageSplit = a.split(",");
          //  a = imageSplit[1];
            Bitmap bitmap = Converter.imageFromText(a);
            bitmap = Converter.scaleBitmapToRegular(bitmap);
            bitmap = Converter.getCroppedBitmap(bitmap);


            navProfilePic.setImageBitmap(bitmap);
            Log.e("hey", "got profile pic response");
        }
        @Override
        public void onFailure(Call<ResponseBody> call, Throwable t) { }
        @Override
        public void onErrorResponse(POJOerror error) { }
        @Override
        public void onEmptyResponse() { }
        @Override
        public void onSuccessfulResponse() {}
        @Override
        public void onNoConnection() {}
    };

    CustomResponseHandler responseHandler = new CustomResponseHandler() {
        @Override
        public void onResponse(HashMap<String, Object> response) { }
        @Override
        public void onPOJOResponse(Object response) {
            Log.e("hey", "got pojo response");
          //  SharedPrefs.getString(act.getBaseContext(), "userInfo", "username")
            SharedPrefs.save(getApplicationContext(),"userInfo", "username",((POJOme) response).getUsername());
            navUsername.setText(((POJOme) response).getUsername());
            navEmail.setText(((POJOme) response).getEmailAddress());
        }
        @Override
        public void onFailure(Call<ResponseBody> call, Throwable t) {
            Log.e("hey", "4");
            Log.e("hey", "got here onFailure");
        }
        @Override
        public void onEmptyResponse() {
            Log.e("hey", "NO RESPONSE");
        }
        @Override
        public void onSuccessfulResponse() { }
        @Override
        public void onNoConnection() { }
        @Override
        public void onErrorResponse(POJOerror error) {
            Log.e("hey", "onErrorResponse");
        }
    };

    CustomResponseHandler rh_motd = new CustomResponseHandler() {
        @Override
        public void onResponse(HashMap<String, Object> response) { }
        @Override
        public void onPOJOResponse(Object response) {
            String motd = (String)response;
            Log.e("hey", "MOTD: " + motd);
            if(!motd.equals("")) {
             //   try {
                    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(MainActivity.this);
                    alertDialogBuilder.setTitle("Napi üzenet");
                    alertDialogBuilder
                            .setMessage(motd)
                            .setCancelable(true)
                            .setPositiveButton("Oké", (dialog, id) -> {
                                dialog.cancel();
                            });
                    AlertDialog alertDialog = alertDialogBuilder.create();
                    alertDialog.show();
               /* } catch (Exception e) {
                    Log.e("hey", "CAUGHT exception");
                } */
            }else{
                Log.e("hey", "Message of the day is not");
            }
        }
        @Override
        public void onFailure(Call<ResponseBody> call, Throwable t) {
            Log.e("hey", "4");
            Log.e("hey", "got here onFailure");
        }
        @Override
        public void onEmptyResponse() {
        }
        @Override
        public void onSuccessfulResponse() { }
        @Override
        public void onNoConnection() { }
        @Override
        public void onErrorResponse(POJOerror error) {
            Log.e("hey", "onErrorResponse");
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Manager.ThreadManager.startThreadIfNotRunning(this);

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        fab_joinGroup = findViewById(R.id.fab_joinGroup);
        fab_joinGroup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Transactor.fragmentJoinGroup(getSupportFragmentManager().beginTransaction());
                fab_joinGroup.setVisibility(View.INVISIBLE);
            }
        });
        toMainFrag = true;

        fab_action = (FloatingActionButton) findViewById(R.id.fab_action);
        fab_action.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
             /*   Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show(); */
                Log.e("hey", "fab_action CLICKed");
                currentFrag = Transactor.getCurrentFragment(getSupportFragmentManager(), false);
                if (currentFrag instanceof GroupMainFragment) {
                    Log.e("hey", "instance of groupmain fragment");
                    ((GroupMainFragment)currentFrag).toCreateTask(getSupportFragmentManager());
                }
                else if (currentFrag instanceof GroupAnnouncementFragment) {
                    ((GroupAnnouncementFragment)currentFrag).toCreateAnnouncement(getSupportFragmentManager());
                }else if (currentFrag instanceof MainAnnouncementFragment) {
                    toCreateAnnouncementFrag();
                }

                else if (currentFrag instanceof GetGroupMembersFragment) {
                    //((GetGroupMembersFragment)currentFrag).toCreateTask();
                }
             //   else if(currentFrag instanceof CreateTaskFragment || currentFrag instanceof GroupsFragment){}
                else if (currentFrag instanceof MainFragment) {
                    toCreateTaskFrag();
                }
                else if (currentFrag instanceof GroupsFragment) {
                    Log.e("hey", "instance of groupmain fragment111");
                    ((GroupsFragment)currentFrag).toCreateGroup(getSupportFragmentManager());
                }
                else {
                 //   toGroupsFrag();
                }
            }
        });
        navView = (NavigationView) findViewById(R.id.nav_view);
        navView.setNavigationItemSelectedListener(this);
        navView.bringToFront();

        View headerView = navView.getHeaderView(0);
        navProfilePic = (ImageView) headerView.findViewById(R.id.imageView_memberProfilePic);
        navUsername = (TextView) headerView.findViewById(R.id.textView_userName);
        navEmail = (TextView) headerView.findViewById(R.id.textView_email);
        navLogout = findViewById(R.id.textView_logout);

        menu_nav = navView.getMenu();

        menu_groups= menu_nav.getItem(2);
        menu_mainGroup = menu_nav.getItem(3);

        drawerLayout = findViewById(R.id.drawer_layout);
        toggle = new ActionBarDrawerToggle(this, drawerLayout, R.string.open, R.string.close);
        drawerLayout.addDrawerListener(toggle);
        toggle.syncState();

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        Activity thisActivity = this;

        navLogout.setOnClickListener(new View.OnClickListener() {
             @Override
             public void onClick(View view) {
                 SharedPrefs.savePref(getBaseContext(), "autoLogin", "autoLogin", false);
                 SharedPrefs.TokenManager.invalidateTokens(getBaseContext());
                 Intent i = new Intent(thisActivity, AuthActivity.class);
                 startActivity(i);

             }
             });
        MiddleMan.newRequest(this, "messageOfTheDay", null, rh_motd, null);

        MiddleMan.newRequest(this, "getMyProfilePic", null, rh_profilePic, null);

        MiddleMan.newRequest(this, "me", null, responseHandler, null);
    }

    @Override
    public void onResume(){
      /*  invalidateOptionsMenu();
        try{
            onCreateOptionsMenu(menu_options);
        }
        catch (NullPointerException e){

        } */
        super.onResume();
      //  setHasOp
        invalidateOptionsMenu();
        Log.e("hey", "onResume is trigered");
    }
    /*
    @Override
    public void onStart(){
        super.onStart();
        Log.e("hey", "onResume is trigered");
        toMainFrag();
    }  */

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
       // super.onCreateOptionsMenu(menu);
        Log.e("hey", "onCreateOptionsMenu asdasd");

        menu_options = menu;
        getMenuInflater().inflate(R.menu.main, menu_options);

        menuItem_createGroup = menu_options.findItem(R.id.action_createGroup);
        menuItem_joinGroup = menu_options.findItem(R.id.action_joinGroup);
        menuItem_leaveGroup = menu_options.findItem(R.id.action_leaveGroup);
        menuItem_profilePic = menu_options.findItem(R.id.action_profilePic);
        menuItem_feedback = menu_options.findItem(R.id.action_feedback);

        if(menuItem_createGroup == null || menuItem_joinGroup == null ){// || menuItem_leaveGroup == null){
            Log.e("hey", "menu items are null");
        }

        if(toMainFrag) {
            toMainFrag();
            toMainFrag = false;
        }
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        Fragment cFrag = Transactor.getCurrentFragment(getSupportFragmentManager(), false);
        if(toggle.onOptionsItemSelected(item)){
            return true;
        }
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_createGroup) {
            Transactor.fragmentCreateGroup(getSupportFragmentManager().beginTransaction());
            return true;
        }
        if (id == R.id.action_joinGroup) {
            Transactor.fragmentJoinGroup(getSupportFragmentManager().beginTransaction());
            return true;
        }
        if (id == R.id.action_leaveGroup) {
            ((GroupTabFragment)cFrag).leaveGroup();
            return true;
        }
        if (id == R.id.action_profilePic) {
            pickImage();
            return true;
        }
        if (id == R.id.action_feedback) {
            Transactor.feedbackActivity(this);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        Log.e("hey", "chechk1");
        int id = item.getItemId();

        currentFrag = Transactor.getCurrentFragment(getSupportFragmentManager(), false);
        if (id == R.id.nav_home) {
            toMainFrag();
        } else if (id == R.id.nav_groups) {
            toGroupsFrag();
        } else if (id == R.id.nav_newGroup) {
           // ((GroupsFragment)currentFrag).toCreateGroup();
            Transactor.fragmentCreateGroup(getSupportFragmentManager().beginTransaction());
        } else if (id == R.id.nav_joinGroup) {
            //((GroupsFragment)currentFrag).
            Transactor.fragmentJoinGroup(getSupportFragmentManager().beginTransaction());
        } else if (id == R.id.nav_tasks) {
            //((GroupsFragment)currentFrag).
            ((GroupTabFragment)currentFrag).setTab(2);
        }else if (id == R.id.nav_groupMembers) {
            //((GroupsFragment)currentFrag).
            ((GroupTabFragment)currentFrag).setTab(1);
        }
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }
    void toGroupsFrag(){
        Transactor.fragmentGroups(getSupportFragmentManager().beginTransaction());
    }
    void toMainFrag(){
        Transactor.fragmentMain(getSupportFragmentManager().beginTransaction());
    }

    void toCreateTaskFrag(){
        Manager.DestManager.setDest(Manager.DestManager.TOCREATETASK);
        Transactor.fragmentGroups(getSupportFragmentManager().beginTransaction());
    }
    void toCreateAnnouncementFrag(){
        Manager.DestManager.setDest(Manager.DestManager.TOCREATEANNOUNCEMENT);
        Transactor.fragmentGroups(getSupportFragmentManager().beginTransaction());
    }

    void logout(){
        Intent i = new Intent(this, AuthActivity.class);
        startActivity(i);
    }
    @Override
    public void onBackPressed() {
        Log.e("hey", "backButton pressed");
        currentFrag = Transactor.getCurrentFragment(getSupportFragmentManager(), true);
        if      (currentFrag instanceof MainFragment) {}
        else if (currentFrag instanceof GroupsFragment) {
            Transactor.fragmentMain(getSupportFragmentManager().beginTransaction());
        }
        else if (currentFrag instanceof GroupTabFragment) {//GroupMainFragment
            Transactor.fragmentGroups(getSupportFragmentManager().beginTransaction());
        }
    /*    else if (currentFrag instanceof CreateTaskFragment) {
            Transactor.fragmentMainGroup(getSupportFragmentManager().beginTransaction(), ((CreateTaskFragment)currentFrag).getGroupId(), ((CreateTaskFragment)currentFrag).getGroupName());
         //   Transactor.fragmentGroupTab(getSupportFragmentManager().beginTransaction(), ((CreateTaskFragment)currentFrag).getGroupId(), ((CreateTaskFragment)currentFrag).getGroupName());
        } */

        else if (currentFrag instanceof GroupMainFragment)    {}

        else if (currentFrag instanceof ViewTaskFragment) {
            if(!((ViewTaskFragment)currentFrag).getGoBackToMain()) {
                Transactor.fragmentMainGroup(getSupportFragmentManager().beginTransaction(), ((ViewTaskFragment) currentFrag).getGroupId(), ((ViewTaskFragment) currentFrag).getGroupName());
            }else{
                Transactor.fragmentMain(getSupportFragmentManager().beginTransaction());
            }
          //  Transactor.fragmentGroupTab(getSupportFragmentManager().beginTransaction(), ((CreateTaskFragment)currentFrag).getGroupId(), ((CreateTaskFragment)currentFrag).getGroupName());

        } else if (currentFrag instanceof CreateSubjectFragment) {
            ((CreateSubjectFragment) currentFrag).goBack();
        } else {
            Log.e("hey", "back button pressed and Else block is being called");
            Transactor.fragmentMain(getSupportFragmentManager().beginTransaction());
        }
    }
    public void onFragmentCreated(){
        currentFrag = Transactor.getCurrentFragment(getSupportFragmentManager(), false);

        if(currentFrag instanceof CreateSubjectFragment) {
         //   fab_createGroup.setVisibility(View.INVISIBLE);
        //    fab_action.setVisibility(View.INVISIBLE);
        }else{
          //  fab_action.setVisibility(View.VISIBLE);
        }

        if (currentFrag instanceof GroupAnnouncementFragment || currentFrag instanceof GroupMainFragment
            || currentFrag instanceof MainAnnouncementFragment || currentFrag instanceof MainFragment ) {
            fab_action.setVisibility(View.VISIBLE);
            if(menuItem_createGroup != null && menuItem_feedback != null && menuItem_joinGroup != null
                    && menuItem_leaveGroup != null && menuItem_profilePic != null) {

                if (currentFrag instanceof MainFragment) {
                    navView.getMenu().getItem(0).setChecked(true);
                    menuItem_createGroup.setVisible(true);
                    menuItem_joinGroup.setVisible(true);
                } else {
                    navView.getMenu().getItem(0).setChecked(false);
                    menuItem_createGroup.setVisible(false);
                    menuItem_joinGroup.setVisible(false);
                }
            }
        } else {
            fab_action.setVisibility(View.INVISIBLE);
        }
        if (currentFrag instanceof GroupsFragment) {
            fab_joinGroup.setVisibility(View.VISIBLE);
            navView.getMenu().getItem(1).setChecked(true);
            fab_action.setVisibility(View.VISIBLE);
        } else {
            fab_joinGroup.setVisibility(View.INVISIBLE);
            navView.getMenu().getItem(1).setChecked(false);
        }
    }

    public void onTabSelected(Fragment currentFrag){
        if(menuItem_createGroup != null && menuItem_feedback != null && menuItem_joinGroup != null
                && menuItem_leaveGroup != null && menuItem_profilePic != null) {
            if (currentFrag instanceof GroupAnnouncementFragment || currentFrag instanceof GroupMainFragment
                    || currentFrag instanceof MainAnnouncementFragment // || currentFrag instanceof GetGroupMembersFragment
                    || currentFrag instanceof MainFragment || currentFrag instanceof GroupsFragment) {
                fab_action.setVisibility(View.VISIBLE);
                if (currentFrag instanceof GroupsFragment) {
                    fab_joinGroup.setVisibility(View.VISIBLE);
                    navView.getMenu().getItem(1).setChecked(true);
                } else {
                    fab_joinGroup.setVisibility(View.INVISIBLE);
                    navView.getMenu().getItem(1).setChecked(false);
                }
                if (currentFrag instanceof MainFragment) {
                    navView.getMenu().getItem(0).setChecked(true);
                    menuItem_createGroup.setVisible(true);
                    menuItem_joinGroup.setVisible(true);
                } else {
                    navView.getMenu().getItem(0).setChecked(false);
                    menuItem_createGroup.setVisible(false);
                    menuItem_joinGroup.setVisible(false);
                }
            } else {
                fab_action.setVisibility(View.INVISIBLE);
            }
        }
    }
    public void setGroupName(String name){
        menu_mainGroup.setTitle("Csoportok: " + name);
    }
    public void pickImage() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("image/*");
        startActivityForResult(intent, PICK_PHOTO_FOR_AVATAR);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == PICK_PHOTO_FOR_AVATAR && resultCode == Activity.RESULT_OK) {
            if (data == null) {
                return;
            }
            try {
                InputStream inputStream = this.getContentResolver().openInputStream(data.getData());
                Uri imageUri = data.getData();
                Bitmap yourSelectedImage = BitmapFactory.decodeStream(inputStream);
                yourSelectedImage = Bitmap.createScaledBitmap(yourSelectedImage, 300, 300, true);
                Bitmap bitmap=Bitmap.createBitmap(yourSelectedImage, 0,0,300, 300);
                HashMap<String, Object> body = new HashMap<>();
                body.put("data", "data:image/jpeg;base64," + Converter.imageToText(bitmap));
                body.put("type", "ppfull");

                MiddleMan.newRequest(this, "setMyProfilePic", body, new CustomResponseHandler() {
                    @Override
                    public void onResponse(HashMap<String, Object> response) { }
                    @Override
                    public void onPOJOResponse(Object response) { }
                    @Override
                    public void onFailure(Call<ResponseBody> call, Throwable t) { }
                    @Override
                    public void onErrorResponse(POJOerror error) {
                        Log.e("hey", "couldnt set profile pic");
                    }
                    @Override
                    public void onEmptyResponse() { }
                    @Override
                    public void onSuccessfulResponse() {
                        MiddleMan.newRequest(thisActivity, "getMyProfilePic", null, rh_profilePic, null);
                    }
                    @Override
                    public void onNoConnection() { }
                }, null);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                Log.e("hey", "file not found!");
            }
        }
        Log.e("hey", "onActivityResult");
    }

}
