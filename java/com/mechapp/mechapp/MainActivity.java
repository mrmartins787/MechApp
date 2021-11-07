package com.mechapp.mechapp;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    public static int SPLASH_SCREEN = 5000;

    Animation topanim, Bottomanim, floating;
    ImageView image;
    TextView text, text2;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        topanim = AnimationUtils.loadAnimation(this, R.anim.logo_animation);
        Bottomanim = AnimationUtils.loadAnimation(this, R.anim.pro_animation);
        floating = AnimationUtils.loadAnimation(this, R.anim.top_animation);
        image = (ImageView) findViewById(R.id.logo);
        // slogan=(TextView)findViewById(R.id.slogan);
        text = (TextView) findViewById(R.id.emech);
        //text2 = (TextView) findViewById(R.id.agent);

        image.setAnimation(topanim);

        text.setAnimation(Bottomanim);
        //text2.setAnimation(floating);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainActivity.this, OnboardScreen.class);
                startActivity(intent);
                finish();
            }
        }, SPLASH_SCREEN);
    }
}