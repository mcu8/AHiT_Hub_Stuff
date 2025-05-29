# HUB Swapper – Template Map

A template map for **HUB Swapper** that lets you create your own hub map **without writing a single line of code**.

> 💡 The mod supports an "addon loader", but due to engine limitations, **only one hub map can be loaded at a time**.

---

## ⚠️ Before You Start

Follow these steps to set everything up properly:

1. **Remove** the Steam version of HUB Swapper.
2. **Download** [mcu8_mods_BH.zip](https://github.com/mcu8/AHiT_Hub_Stuff/tree/main/Releases/mcu8_mods_BH.zip).
3. Extract the `mcu8_mods_BH` folder into your local `Mods` directory.
4. Launch the **Mod Manager**, click the **HUB Swapper** mod icon, then click `[</>]` and press the **"Compile scripts"** button.
5. Wait until the script compilation is complete.
6. Click the **🚀 rocket icon**, press **"Cook Mod"**, and also wait for it to finish.

✅ You're now ready to start building your own map!

---

## 🛠️ Creating Your Custom Map

1. Create a **new mod** using the Modding Tools and open the editor.
2. Load the provided template map:  
   `hubexmap_ExampleHubMap.umap`
3. **Do not modify** the original template. Instead, save it as:  
   `hubexmap_<your_custom_name>.umap`  
   *(Make sure to use the `hubexmap_` prefix!)*
4. Save the new map into your mod’s `Maps` folder.
5. Load your saved map — and enjoy modding!

---

## 📂 Optional: Notify Players About Missing HUB Swapper

Inside the `Classes` folder, you'll find an **optional script** that displays a message to players if **HUB Swapper is not installed**.  
It also suggests where to download it.

If you'd like to use this feature, simply **copy the file(s)** from the provided `Classes` folder into your mod's own `Classes` directory.

---

## 📦 Steam Workshop Reminder

> Don’t forget to **add HUB Swapper as a dependency** when uploading your mod to the Steam Workshop!

---

## 👤 Author

Created by **[m_cu8](https://hat.ovh)**  
🔵 [bsky.app/profile/m-cu.be](https://bsky.app/profile/m-cu.be)
