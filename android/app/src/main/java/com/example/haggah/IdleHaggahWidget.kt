package com.example.haggah

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.widget.RemoteViews
import org.json.JSONObject
import org.json.JSONTokener
import java.io.File
import kotlin.math.max
import kotlin.math.min

const val GO_PREV = "com.example.haggah.GOPREV"
const val GO_NEXT = "com.example.haggah.GONEXT"
const val SHAREDPREF = "com.example.haggah"

/**
 * Implementation of App Widget functionality.
 */
class IdleHaggahWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val views = RemoteViews(context.packageName, R.layout.idle_haggah_widget)

        views.setOnClickPendingIntent(R.id.imageButton, getPendingSelfIntent(context, GO_PREV))
        views.setOnClickPendingIntent(R.id.imageButton2, getPendingSelfIntent(context, GO_NEXT))

        val tmp = getVerses(context)

        views.setTextViewText(R.id.textView1, tmp.title)
        views.setTextViewText(R.id.textView2, tmp.address)
        views.setTextViewText(R.id.textView3, tmp.content)

        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null) {
            return
        }

        val setting = context.getSharedPreferences(SHAREDPREF, 0)
        val verseIdx = setting.getInt("verseIdx", 0)
        val storageLength = setting.getLong("storageLength", 1)

        val editor = setting.edit()

        val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, this.javaClass))

        when (intent?.action) {
            GO_PREV -> {
                editor.putInt("verseIdx", max(verseIdx - 1, 0))
                editor.apply()
                this.onUpdate(context, AppWidgetManager.getInstance(context), ids)
            }
            GO_NEXT -> {
                editor.putInt("verseIdx", min((verseIdx + 1), (storageLength - 1).toInt()))
                editor.apply()
                this.onUpdate(context, AppWidgetManager.getInstance(context), ids)
            }
            else -> {
                super.onReceive(context, intent)
            }
        }

        editor.commit()
    }

    var internalStorageDir = ""
    var dat: DataObj = DataObj(
        "B2B",
        "전 12:1",
        "너는 청년의 때에 너의 창조주를 기억하라 곧 곤고한 날이 이르기 전에 나는 아무 낙이 없다고 할 해들이 가깝기 전에"
    )

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    fun getPendingSelfIntent(context: Context, action: String): PendingIntent {
        val intent = Intent(context, IdleHaggahWidget::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_MUTABLE)
    }

    fun openDatabase(context: Context): SQLiteDatabase? {
        internalStorageDir = context.filesDir.parentFile!!.path

        val params = SQLiteDatabase.OpenParams.Builder().build()
        return SQLiteDatabase.openDatabase(File("$internalStorageDir/databases/bible/bible.db"), params)
    }

    fun getVerses(context: Context) : DataObj {
        val setting = context.getSharedPreferences(SHAREDPREF, 0)
        val editor = setting.edit()
        var verseIdx = setting.getInt("verseIdx", 0)

        val database = openDatabase(context)

        var chimrye = false
        var haggah = false
        val settingFile = File("$internalStorageDir/app_flutter/settings.json")
        if (settingFile.exists()) {
            val fileJson = JSONTokener(settingFile.readLines().joinToString("\n")).nextValue() as JSONObject

            if (fileJson.has("chimrye")) {
                chimrye = fileJson.getBoolean("chimrye")
            }
            if (fileJson.has("haggah")) {
                haggah = fileJson.getBoolean("haggah")
            }
        }

        val fileNames = File("$internalStorageDir/app_flutter/collections").listFiles()?.map { v -> v.nameWithoutExtension }

        if (fileNames?.isEmpty() == true) {
            return DataObj(
                "",
                "",
                "말씀 묶음이 존재하지 않습니다"
            )
        }

        val storageName = setting.getString("storageName", null)

        val jsonFile = File("$internalStorageDir/app_flutter/collections/${storageName ?: fileNames!![0]}.json")
        val json = JSONTokener(jsonFile.readLines().joinToString("\n")).nextValue() as JSONObject

        val title = json.getString("title")
        val allVerses = json.getJSONArray("verses")

        if (!setting.contains("storageLength")) {
            editor.putLong("storageLength", allVerses.length().toLong())
        } else {
            val maxLen = setting.getLong("storageLength", 0)
            if (verseIdx >= maxLen) {
                verseIdx = maxLen.toInt() - 1
                editor.putInt("verseIdx", verseIdx)
            }
        }
        editor.commit()

        val verseArray = allVerses.getJSONObject(verseIdx).getJSONArray("verses")

        var book = 0
        var chapter = 0
        var verses = arrayOf<Int>()

        for (i in 0 ..< verseArray.length()) {
            val singleObj = verseArray.getJSONObject(i)
            book = singleObj.getInt("book")
            chapter = singleObj.getInt("chapter")
            verses += singleObj.getInt("verse")
        }

        if (database == null || !database.isOpen) {
            openDatabase(context)
        }

        val cursor = database!!.rawQuery(
            """
               SELECT * FROM ZVERSE 
                    WHERE ZVERSE_NUMBER IN (${verses.joinToString(",")}) 
                    and ZTOCHAPTER = (
                        SELECT Z_PK FROM ZCHAPTER 
                            WHERE ZCHAPTER_NUMBER = ? 
                            AND ZTOBOOK = (
                                SELECT Z_PK FROM ZBOOK WHERE ZBOOK_INDEX=?
                            )
                    ) 
            """,
            arrayOf( "$chapter", "${book +1}")
        )

        var contents = arrayOf<String>();
        val cIdx = cursor.getColumnIndex("ZVERSE_CONTENT")

        cursor.moveToFirst()
        while (!cursor.isAfterLast) {
            contents += cursor.getString(cIdx)
            cursor.moveToNext()
        }

        cursor.close()
        database.close()

        return DataObj(
            title,
            "${BibleData.shortNames[book]} $chapter : ${BibleData.intArrToString(verses)}",
            contents.joinToString(" ") { parseVerseDataMin( it.substring(0,it.length-1), chimrye = chimrye, haggah = haggah) }
//            contents.joinToString("")
//            fileNames?.joinToString(" ").toString()
        )
    }
}

class DataObj(val title: String, val address: String, val content: String)

internal object BibleData {
    val shortNames = arrayOf(
        "창",
        "출",
        "레",
        "민",
        "신",
        "수",
        "삿",
        "룻",
        "삼상",
        "삼하",
        "왕상",
        "왕하",
        "대상",
        "대하",
        "스",
        "느",
        "에",
        "욥",
        "시",
        "잠",
        "전",
        "아",
        "사",
        "렘",
        "애",
        "겔",
        "단",
        "호",
        "욜",
        "암",
        "옵",
        "욘",
        "미",
        "나",
        "합",
        "습",
        "학",
        "슥",
        "말",
        "마",
        "막",
        "눅",
        "요",
        "행",
        "롬",
        "고전",
        "고후",
        "갈",
        "엡",
        "빌",
        "골",
        "살전",
        "살후",
        "딤전",
        "딤후",
        "딛",
        "몬",
        "히",
        "약",
        "벧전",
        "벧후",
        "요일",
        "요이",
        "요삼",
        "유",
        "계",
    )

    fun intArrToString(array: Array<Int>): String {
        var tmp = array.first()
        var count = 0
        var v = "$tmp"

        for (i in 0..<array.size) {
            if (tmp == array[i]) {
                tmp++
                count++
            } else {
                if (count == 1) {
                    v += ","
                } else {
                    v += "-${tmp - 1},"
                }
                count = 1
                v += "${array[i]}"
                tmp = array[i] + 1
            }
        }
        if (count > 1) {
            v += "-${tmp - 1}"
        }

        return v
    }
}

fun parseVerseDataMin(data: String, chimrye: Boolean = false, haggah: Boolean = false): String {
    var copy = data
    if (chimrye) copy = copy.replace("세례", "침례");
    if (haggah) {
        copy = copy
            .replace("묵상이", "하가가")
            .replace("묵상", "하가");
    }
    return copy
        .replace(Regex("^\\[[^\\[]*]|어떤 사본에는.*"), "")
        .trim();
}