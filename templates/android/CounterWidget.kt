// ============================================================
// flutter_home_widget — Android Glance Widget 템플릿
//
// 사용법:
// 1. 이 파일을 android/app/src/main/kotlin/<your/package>/ 에 복붙
// 2. package 선언을 본인 패키지명으로 교체
// 3. WIDGET_NAME 을 FlutterHomeWidget.update(widgetName:) 와 동일하게 설정
// 4. AndroidManifest.xml 에 리시버 등록 (아래 주석 참고)
// 5. res/xml/counter_widget_info.xml 추가 (CounterWidgetInfo.xml 파일 참고)
// ============================================================

package com.yourpackage // TODO: 본인 패키지명으로 교체

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.size
import androidx.glance.layout.wrapContentSize
import androidx.glance.text.Text
import com.leejia.flutter_home_widget.FlutterHomeWidgetPlugin
import org.json.JSONArray
import java.io.File

// MARK: - 설정값
private const val WIDGET_NAME = "CounterWidget" // FlutterHomeWidget.update(widgetName:) 과 동일하게
private const val PREFS_NAME  = "flutter_home_widget"

// MARK: - 액션 모델

data class WidgetAction(
    val id: String,
    val left: Float,
    val top: Float,
    val width: Float,
    val height: Float,
)

// MARK: - Glance Widget

class CounterWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val imagePath = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString("${WIDGET_NAME}_image_path", null)

        val actionsJson = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString("${WIDGET_NAME}_actions", "[]")

        val actions = parseActions(actionsJson ?: "[]")

        provideContent {
            CounterWidgetContent(
                context = context,
                imagePath = imagePath,
                actions = actions,
            )
        }
    }

    private fun parseActions(json: String): List<WidgetAction> {
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { i ->
                val obj = array.getJSONObject(i)
                WidgetAction(
                    id     = obj.getString("id"),
                    left   = obj.getDouble("left").toFloat(),
                    top    = obj.getDouble("top").toFloat(),
                    width  = obj.getDouble("width").toFloat(),
                    height = obj.getDouble("height").toFloat(),
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }
}

// MARK: - Composable UI

@Composable
private fun CounterWidgetContent(
    context: Context,
    imagePath: String?,
    actions: List<WidgetAction>,
) {
    Box(modifier = GlanceModifier.fillMaxSize()) {
        // Flutter가 렌더링한 이미지
        if (imagePath != null && File(imagePath).exists()) {
            val bitmap = BitmapFactory.decodeFile(imagePath)
            Image(
                provider = ImageProvider(bitmap),
                contentDescription = null,
                modifier = GlanceModifier.fillMaxSize(),
            )
        } else {
            Text("위젯을 업데이트 중...")
        }

        // 투명 탭 오버레이 (액션마다 하나씩)
        actions.forEach { action ->
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .clickable(
                        onClick = actionStartActivity<MainActivity>(
                            // MainActivity 에서 intent extras 로 actionId 수신
                            parameters = androidx.glance.action.ActionParameters.Builder()
                                .set(
                                    androidx.glance.action.ActionParameters.Key<String>("actionId"),
                                    action.id
                                )
                                .build()
                        )
                    )
            ) { /* 투명 */ }
        }
    }
}

// MARK: - AppWidget Receiver

class CounterWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = CounterWidget()

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // flutter_home_widget 플러그인이 브로드캐스트로 새로고침 요청
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            goAsync()
        }
    }
}

/*
 AndroidManifest.xml 에 아래 추가:

 <receiver
     android:name=".CounterWidgetReceiver"
     android:exported="true">
     <intent-filter>
         <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
     </intent-filter>
     <meta-data
         android:name="android.appwidget.provider"
         android:resource="@xml/counter_widget_info" />
 </receiver>
*/
