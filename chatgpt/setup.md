# Scripter in ChatGPT

There are two ways to use it. Pick the one your plan allows.

## Option A: upload it as a skill (Business, Enterprise, Edu and Healthcare plans)

1. Open ChatGPT and go to **Plugins → Skills → Create → Upload from your computer**.
2. Choose `dist\scripter.zip` from this folder.
3. It turns on by itself for design work. To call it directly, type `@scripter` in a message.

If you don't see **Skills**, your plan or workspace doesn't allow custom skills. Use Option B.

## Option B: make a Custom GPT (any paid plan)

1. Go to **Explore GPTs → Create** (or **My GPTs → Create a GPT**) and open the **Configure** tab.
2. Fill in:
   - **Name:** `Scripter`
   - **Description:** `Checks how a thing works and whether your design is possible, buildable and the best approach, before building it. No praise.`
   - **Instructions:** paste everything in `chatgpt\instructions.txt`.
3. **Conversation starters** (add these four):
   - `Here's my idea for a new product. Will it work?`
   - `Turn this sketch into a 3D model.`
   - `Is this app idea possible to build?`
   - `Review my design and tell me what's wrong with it.`
4. **Knowledge:** upload the four files from `scripter\skills\scripter\references\`:
   - `physical-products.md`
   - `sketch-to-3d.md`
   - `software-systems.md`
   - `spaces-structures.md`
5. **Capabilities:** turn on **Code Interpreter & Data Analysis**, which it uses for calculations. Web search is optional.
6. Click **Create** and set sharing to **Only me** (or share the link if you want).

To use it, pick **Scripter** from the sidebar and start a chat there. Normal ChatGPT chats aren't affected.

## Updating it later

After editing the files, run `.\build.ps1` again. Then either re-upload the zip (Option A) or paste the new `instructions.txt` and re-upload any changed reference files in the GPT's Configure tab (Option B).
