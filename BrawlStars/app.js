/* ============================================================
   Brawl Stars Tracker — app.js
   ============================================================ */

   const API = 'index.php';
   let currentUser = null;
   let allBrawlers = [];
   
   /* ---- HTTP helper ---- */
   async function api(params) {
     const isGet = !params.method || params.method === 'GET';
     let url = API, opts = { method: 'GET' };
     if (isGet) {
       url += '?' + new URLSearchParams(params.query || {}).toString();
     } else {
       opts = { method: 'POST', body: new URLSearchParams(params.body || {}) };
     }
     const res = await fetch(url, opts);
     return res.json();
   }
   
   // Rimuove il # dal tag prima di inviarlo (il # nell'URL tronca la query string)
   // Il backend lo riaggiungerà sempre in normalizeTag
   function stripHash(tag) {
     return tag ? tag.replace(/^#/, '') : '';
   }
   
   /* ---- UI helpers ---- */
   function alert_(el, msg, type = 'error') {
     if (typeof el === 'string') el = document.getElementById(el);
     el.innerHTML = `<div class="alert alert-${type}">${msg}</div>`;
   }
   
   function rarityClass(r = '') {
     return 'rarity-' + (r.toLowerCase().replace(' ', '-') || 'common');
   }
   
   function fmt(n) {
     return (n || 0).toLocaleString('it');
   }
   
   function escHtml(s) {
     if (!s) return '';
     return String(s)
       .replace(/&/g, '&amp;')
       .replace(/</g, '&lt;')
       .replace(/>/g, '&gt;')
       .replace(/"/g, '&quot;');
   }
   
   /* ---- Tabs ---- */
   function switchTab(name) {
     const names = ['profilo', 'search', 'following', 'builds', 'top'];
     document.querySelectorAll('.tab').forEach((t, i) =>
       t.classList.toggle('active', names[i] === name)
     );
     document.querySelectorAll('.tab-panel').forEach(p =>
       p.classList.remove('active')
     );
     document.getElementById('tab-' + name).classList.add('active');
   
     if (name === 'profilo')   loadProfilo();
     if (name === 'following') loadFollowing();
     if (name === 'builds')    { loadBuilds(); loadBrawlersForForm(); }
     if (name === 'top')       loadTop();
   }
   
   /* ---- Login / Logout ---- */
   async function doLogin() {
     const tag = document.getElementById('login-tag').value.trim();
     if (!tag) return;
     const alertEl = document.getElementById('login-alert');
     alertEl.innerHTML = '<div class="alert" style="background:var(--bg)"><span class="spinner"></span>Accesso in corso…</div>';
     try {
       const data = await api({ query: { action: 'login', tag: stripHash(tag) } });
       if (!data.success) { alert_(alertEl, data.message); return; }
       currentUser = data.player;
       showDashboard();
     } catch (e) {
       alert_(alertEl, 'Errore di connessione.');
     }
   }
   
   function showDashboard() {
     document.getElementById('login-section').style.display = 'none';
     document.getElementById('dashboard').style.display = 'block';
     const badge = document.getElementById('user-badge');
     badge.style.display = 'flex';
     document.getElementById('badge-name').textContent = currentUser.name;
     document.getElementById('badge-tag').textContent = currentUser.tag;
     loadProfilo();
   }
   
   function logout() {
     fetch(API + '?action=logout');
     currentUser = null;
     allBrawlers = [];
     document.getElementById('login-section').style.display = 'block';
     document.getElementById('dashboard').style.display = 'none';
     document.getElementById('user-badge').style.display = 'none';
     document.getElementById('login-alert').innerHTML = '';
     document.getElementById('login-tag').value = '';
   }
   
   /* ---- Profilo ---- */
   function loadProfilo() {
     const el = document.getElementById('profilo-content');
     if (!currentUser) return;
     const p = currentUser;
     const clubHtml = clubBadgeHtml(p, 'showClubFromProfilo');
   
     el.innerHTML = `
       <div class="card">
         <div class="player-header">
           <div>
             <div class="player-name">${escHtml(p.name)}</div>
             <div class="player-tag">${p.tag}</div>
           </div>
           ${clubHtml}
         </div>
         <div class="stats-grid-2">
           <div class="stat-cell-bg">
             <div class="stat-label">Trofei attuali</div>
             <div class="stat-value">${fmt(p.trophies)}</div>
           </div>
           <div class="stat-cell-bg">
             <div class="stat-label">Massimo storico</div>
             <div class="stat-value">${fmt(p.highestTrophies)}</div>
           </div>
         </div>
         <div class="stats-grid-3">
           <div class="stat-cell"><div class="stat-label">Vittorie 3vs3</div><div class="stat-value">${fmt(p['3vs3Victories'])}</div></div>
           <div class="stat-cell"><div class="stat-label">Solo</div><div class="stat-value">${fmt(p.soloVictories)}</div></div>
           <div class="stat-cell"><div class="stat-label">Duo</div><div class="stat-value">${fmt(p.duoVictories)}</div></div>
         </div>
         <div class="stats-grid-3" style="margin-bottom:1.25rem;">
           <div class="stat-cell"><div class="stat-label">Livello Exp</div><div class="stat-value">${p.expLevel || 0}</div></div>
           <div class="stat-cell"><div class="stat-label">Prestige</div><div class="stat-value">${fmt(p.totalPrestigeLevel)}</div></div>
           <div class="stat-cell"><div class="stat-label">Trofei max</div><div class="stat-value">${fmt(p.highestTrophies)}</div></div>
         </div>
         <button class="secondary" onclick="refreshProfilo()">↻ Aggiorna dati</button>
       </div>
       <div id="profilo-club"></div>
     `;
   }
   
   async function showClubFromProfilo(clubTagEncoded, clubName) {
     const el = document.getElementById('profilo-club');
     el.innerHTML = `<div class="card"><span class="spinner"></span> Caricamento membri…</div>`;
     const clubTag = decodeURIComponent(clubTagEncoded);
     const data = await api({ query: { action: 'club_members', tag: clubTag } });
     if (!data.success) {
       el.innerHTML = `<div class="alert alert-error">${data.message}</div>`;
       return;
     }
     el.innerHTML = renderClubMembers(data.club, data.members);
   }
   
   async function refreshProfilo() {
     const data = await api({ query: { action: 'login', tag: stripHash(currentUser.tag) } });
     if (data.success) { currentUser = data.player; loadProfilo(); }
   }
   
   /* ---- Search ---- */
   async function doSearch() {
     const tag = document.getElementById('search-tag').value.trim();
     if (!tag) return;
     hideClub();
     const el = document.getElementById('search-result');
     el.innerHTML = '<div style="color:var(--text-hint);font-size:13px"><span class="spinner"></span>Ricerca…</div>';
     try {
       const data = await api({ query: { action: 'search', tag: stripHash(tag) } });
       if (!data.success) {
         el.innerHTML = `<div class="alert alert-error">${data.message}</div>`;
         return;
       }
       const p = data.player;
       const followData = await api({ query: { action: 'following', tag: stripHash(currentUser.tag) } });
       const isFollowing = followData.success && followData.following.some(f => f.tag === p.tag);
       el.innerHTML = renderPlayerCard(p, isFollowing);
     } catch (e) {
       el.innerHTML = '<div class="alert alert-error">Errore di connessione.</div>';
     }
   }
   
   function renderPlayerCard(p, isFollowing) {
     const clubHtml = clubBadgeHtml(p, 'showClub');
     const followBtn = p.tag === currentUser?.tag ? '' :
       isFollowing
         ? `<button class="secondary" onclick="doUnfollow('${p.tag}','search')">Rimuovi dai preferiti</button>`
         : `<button class="secondary" onclick="doFollow('${p.tag}')">+ Preferiti</button>`;
   
     return `<div class="card" style="margin-top:0;">
       <div class="player-header">
         <div>
           <div class="player-name">${escHtml(p.name)}</div>
           <div class="player-tag">${p.tag}</div>
         </div>
         <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
           ${clubHtml}
           ${followBtn}
         </div>
       </div>
       <div class="stats-grid-3" style="margin-bottom:0;">
         <div class="stat-cell"><div class="stat-label">Trofei</div><div class="stat-value">${fmt(p.trophies)}</div></div>
         <div class="stat-cell"><div class="stat-label">Massimo</div><div class="stat-value">${fmt(p.highestTrophies)}</div></div>
         <div class="stat-cell"><div class="stat-label">Livello</div><div class="stat-value">${p.expLevel || 0}</div></div>
         <div class="stat-cell"><div class="stat-label">3vs3</div><div class="stat-value">${fmt(p['3vs3Victories'])}</div></div>
         <div class="stat-cell"><div class="stat-label">Solo</div><div class="stat-value">${fmt(p.soloVictories)}</div></div>
         <div class="stat-cell"><div class="stat-label">Duo</div><div class="stat-value">${fmt(p.duoVictories)}</div></div>
       </div>
       <div id="follow-alert"></div>
     </div>`;
   }
   
   /* ---- Club ---- */
   function getClubTag(p) {
     if (p.club && typeof p.club === 'object') return p.club.tag || '';
     return p.club_tag || '';
   }
   
   function getClubName(p) {
     if (p.club && typeof p.club === 'object') return p.club.name || '';
     if (typeof p.club === 'string') return p.club;
     return '';
   }
   
   function clubBadgeHtml(p, onclickFn) {
     const name = getClubName(p);
     const tag  = getClubTag(p);
     if (!name) return `<span style="font-size:13px;color:var(--text-hint)">Nessun club</span>`;
     if (tag) {
       return `<span class="club-badge" onclick="${onclickFn}('${encodeURIComponent(tag)}','${escHtml(name)}')" title="Clicca per vedere i membri">${escHtml(name)}</span>`;
     }
     return `<span class="club-badge" onclick="askClubTag('${escHtml(name)}')" title="Inserisci tag club manualmente">${escHtml(name)} 🔍</span>`;
   }
   
   function askClubTag(clubName) {
     const tag = prompt(`Inserisci il tag del club "${clubName}" (es. #ABC123):`);
     if (tag && tag.trim()) showClub(encodeURIComponent(tag.trim()), clubName);
   }
   
   async function showClub(clubTagEncoded, clubName) {
     const clubTag = decodeURIComponent(clubTagEncoded);
     const panel   = document.getElementById('club-panel');
     const content = document.getElementById('club-content');
     document.getElementById('search-result').style.display = 'none';
     panel.style.display = 'block';
     content.innerHTML = `<div class="card"><span class="spinner"></span> Caricamento membri di ${escHtml(clubName)}…</div>`;
     const data = await api({ query: { action: 'club_members', tag: clubTag } });
     if (!data.success) {
       content.innerHTML = `<div class="alert alert-error">${data.message}</div>`;
       return;
     }
     content.innerHTML = renderClubMembers(data.club, data.members);
   }
   
   function renderClubMembers(club, members) {
     const rows = members.map(m => `
       <div class="member-row">
         <div>
           <div class="member-name">${escHtml(m.name)}</div>
           <div class="member-tag">${m.tag}</div>
         </div>
         <div style="font-size:13px;color:var(--text-muted);">${m.role || '—'}</div>
         <div style="font-size:13px;font-weight:500;">${fmt(m.trophies)} 🏆</div>
         <button class="secondary" style="font-size:12px;height:28px;" onclick="searchMember('${m.tag}')">Cerca</button>
       </div>
     `).join('');
   
     return `<div class="card">
       <div class="player-header">
         <div>
           <div class="player-name">${escHtml(club.name)}</div>
           <div class="player-tag">${club.tag}</div>
         </div>
         <span style="font-size:13px;color:var(--text-muted);">${members.length} membri · ${fmt(club.trophies)} 🏆</span>
       </div>
       <div class="member-row header">
         <span>Player</span><span>Ruolo</span><span>Trofei</span><span></span>
       </div>
       ${rows}
     </div>`;
   }
   
   function searchMember(tag) {
     hideClub();
     document.getElementById('search-tag').value = tag;
     doSearch();
   }
   
   function hideClub() {
     document.getElementById('club-panel').style.display = 'none';
     document.getElementById('search-result').style.display = 'block';
   }
   
   /* ---- Follow / Unfollow ---- */
   async function doFollow(targetTag) {
     const el = document.getElementById('follow-alert');
     const data = await api({ method: 'POST', body: { action: 'follow', my_tag: stripHash(currentUser.tag), target_tag: stripHash(targetTag) } });
     if (el) alert_(el, data.message, data.success ? 'success' : 'error');
     if (data.success) doSearch();
   }
   
   async function doUnfollow(targetTag, context) {
     await api({ method: 'POST', body: { action: 'unfollow', my_tag: stripHash(currentUser.tag), target_tag: stripHash(targetTag) } });
     if (context === 'search') doSearch();
     else loadFollowing();
   }
   
   /* ---- Following list ---- */
   async function loadFollowing() {
     const el = document.getElementById('following-list');
     el.innerHTML = '<div style="color:var(--text-hint);font-size:13px"><span class="spinner"></span>Caricamento…</div>';
     const data = await api({ query: { action: 'following', tag: stripHash(currentUser.tag) } });
     if (!data.success || !data.following.length) {
       el.innerHTML = '<div class="empty-state">Nessun preferito salvato.</div>';
       return;
     }
     el.innerHTML = `<div class="card" style="margin-bottom:0;">` +
       data.following.map(f => `
         <div class="list-item">
           <div>
             <div class="item-name">${escHtml(f.name)}</div>
             <div class="item-sub">${f.tag}</div>
           </div>
           <div style="display:flex;align-items:center;gap:12px;">
             <span class="item-meta">${fmt(f.trophies)} 🏆</span>
             <button class="danger-btn" onclick="doUnfollow('${f.tag}','following')">Rimuovi</button>
           </div>
         </div>`
       ).join('') + `</div>`;
   }
   
   /* ---- Build form ---- */
   async function loadBrawlersForForm() {
     if (allBrawlers.length > 0) return;
     const data = await api({ query: { action: 'brawlers' } });
     if (!data.success) return;
     allBrawlers = data.brawlers;
     const sel = document.getElementById('build-brawler');
     sel.innerHTML = '<option value="">— Seleziona brawler —</option>';
     allBrawlers.forEach(b => {
       const opt = document.createElement('option');
       opt.value = b.id;
       opt.textContent = b.name;
       sel.appendChild(opt);
     });
   }
   
   function onBrawlerChange() {
     const brawlerId = parseInt(document.getElementById('build-brawler').value);
     const brawler = allBrawlers.find(b => parseInt(b.id) === brawlerId);
     const spSel     = document.getElementById('build-starpower');
     const gSel      = document.getElementById('build-gadget');
   
     spSel.innerHTML = '<option value="">— Nessuna starpower —</option>';
     gSel.innerHTML  = '<option value="">— Nessun gadget —</option>';
   
     if (!brawler) return;
   
     (brawler.starpowers || []).forEach(sp => {
       const opt = document.createElement('option');
       opt.value = sp.id;
       opt.textContent = sp.name;
       spSel.appendChild(opt);
     });
   
     (brawler.gadgets || []).forEach(g => {
       const opt = document.createElement('option');
       opt.value = g.id;
       opt.textContent = g.name;
       gSel.appendChild(opt);
     });
   }
   
   async function saveBuild() {
     const brawlerId   = document.getElementById('build-brawler').value;
     const starpowerId = document.getElementById('build-starpower').value;
     const gadgetId    = document.getElementById('build-gadget').value;
     if (!brawlerId) { alert_('build-alert', 'Seleziona un brawler.'); return; }
   
     const body = { action: 'save_build', brawler_id: brawlerId };
     if (starpowerId) body.starpower_id = starpowerId;
     if (gadgetId)    body.gadget_id    = gadgetId;
   
     const data = await api({ method: 'POST', body });
     alert_('build-alert', data.message, data.success ? 'success' : 'error');
     if (data.success) loadBuilds();
   }
   
   /* ---- My builds ---- */
   async function loadBuilds() {
     const el = document.getElementById('builds-list');
     el.innerHTML = '<div style="color:var(--text-hint);font-size:13px"><span class="spinner"></span>Caricamento…</div>';
     const data = await api({ query: { action: 'my_builds' } });
     if (!data.success || !data.builds.length) {
       el.innerHTML = '<div class="empty-state">Nessuna build salvata. Creane una qui sopra!</div>';
       return;
     }
     el.innerHTML = `<div class="card" style="margin-bottom:0;">` +
       data.builds.map(b => `
         <div class="list-item">
           <div style="display:flex;align-items:center;gap:10px;flex:1;flex-wrap:wrap;">
             <span style="font-weight:500;font-size:14px;min-width:80px;">${escHtml(b.brawler_name)}</span>
             
             <span style="font-size:13px;color:var(--text-muted);">
               ${b.starpower_name ? '⭐ ' + escHtml(b.starpower_name) : '<span style="color:var(--text-hint)">Nessuna SP</span>'}
               &nbsp;·&nbsp;
               ${b.gadget_name ? '🔧 ' + escHtml(b.gadget_name) : '<span style="color:var(--text-hint)">Nessun gadget</span>'}
             </span>
           </div>
           <button class="danger-btn" onclick="removeBuild(${b.combination_id})">Rimuovi</button>
         </div>`
       ).join('') + `</div>`;
   }
   
   async function removeBuild(id) {
     await api({ method: 'POST', body: { action: 'remove_build', combination_id: id } });
     loadBuilds();
   }
   
   /* ---- Top builds ---- */
   async function loadTop() {
     const el = document.getElementById('top-list');
     el.innerHTML = '<div style="color:var(--text-hint);font-size:13px"><span class="spinner"></span>Caricamento…</div>';
     const data = await api({ query: { action: 'top_builds', limit: 10 } });
     if (!data.success || !data.builds.length) {
       el.innerHTML = '<div class="empty-state">Nessuna build nel database.</div>';
       return;
     }
     el.innerHTML = `<div class="card" style="margin-bottom:0;">
       <div class="top-row header">
         <span>#</span><span>Brawler</span><span>Starpower</span><span>Gadget</span><span class="top-count">Utenti</span>
       </div>
       ${data.builds.map((b, i) => `
         <div class="top-row">
           <span style="color:var(--text-hint)">${i + 1}</span>
           <span style="font-weight:500">${escHtml(b.brawler_name)}</span>
           <span style="color:var(--text-muted)">${b.starpower_name ? escHtml(b.starpower_name) : '—'}</span>
           <span style="color:var(--text-muted)">${b.gadget_name ? escHtml(b.gadget_name) : '—'}</span>
           <span class="top-count">${b.users_count}</span>
         </div>`
       ).join('')}
     </div>`;
   }
   
   /* ---- Enter key ---- */
   document.getElementById('login-tag').addEventListener('keydown', e => {
     if (e.key === 'Enter') doLogin();
   });
   document.addEventListener('DOMContentLoaded', () => {
     document.getElementById('search-tag')?.addEventListener('keydown', e => {
       if (e.key === 'Enter') doSearch();
     });
   });