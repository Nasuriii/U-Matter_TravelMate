import {useEffect,useRef,useState} from 'react';
import {Users,UserCheck,UserX,Shield,Search,ArrowUpRight,RefreshCw,TriangleAlert,History,LayoutDashboard,ClipboardCheck,ChartNoAxesCombined} from 'lucide-react';
import {Button} from '../components/ui/button';
import {Modal} from './modal';
import {PageHeading,ErrorState,LoadingCards,EmptyState} from './shared';
import {client,useIdentity,currentIdentity,errorMessage} from './state';
import {confirmAction} from '../action-confirm';
import {toast} from '../ui';
import {FilterSelect} from './filter-select';
import {AdminAppeals} from './account-appeals';
import {PageNavigation} from './page-navigation';
type UserRow={id:string;full_name:string;email:string;roles:string[];account_status:string;created_at:string;updated_at:string};
type Account=UserRow&{address:string|null;trips:number;bookings:number;listings:number;audit:{previous_status:string;next_status:string;reason:string;actor_name:string;created_at:string}[]};
type Directory={items:UserRow[];total:number;counts:{total:number;active:number;suspended:number;admins:number}};
const date=(value:string)=>new Date(value).toLocaleDateString('en-PH',{year:'numeric',month:'short',day:'numeric'});
const roleLabel=(roles:string[])=>roles.map(r=>r==='business_owner'?'Business owner':r==='admin'?'Administrator':r==='traveler'?'Traveler':r).join(' · ')||'No assigned role';
export function UserManagement(){
 const identity=useIdentity(),params=new URLSearchParams(location.hash.split('?')[1]);
 const [query,setQuery]=useState(''),[role,setRole]=useState(params.get('role')==='owner'?'business_owner':'all'),[status,setStatus]=useState('all'),[offset,setOffset]=useState(0),[version,setVersion]=useState(0);
 const [directory,setDirectory]=useState<Directory|null>(null),[loading,setLoading]=useState(true),[error,setError]=useState('');
 const [selected,setSelected]=useState<string|null>(null),[detail,setDetail]=useState<Account|null>(null),[detailError,setDetailError]=useState(''),[detailVersion,setDetailVersion]=useState(0),[reason,setReason]=useState(''),[saving,setSaving]=useState(false);
 const currentSelection=useRef(selected);currentSelection.current=selected;
 useEffect(()=>{let live=true;setLoading(true);setError('');setDirectory(null);const timer=setTimeout(()=>{void Promise.resolve(client.rpc('admin_user_directory',{p_query:query.trim(),p_role:role,p_status:status,p_offset:offset})).then(({data,error:problem})=>{if(!live)return;if(problem)throw problem;const next=data as Directory;if(!next.items.length&&offset>0){setOffset(Math.max(0,offset-25));return;}setDirectory(next);setLoading(false);}).catch(e=>{if(live){setError(errorMessage(e));setLoading(false);}});},250);return()=>{live=false;clearTimeout(timer);};},[identity.id,query,role,status,offset,version]);
 useEffect(()=>{let live=true;setDetail(null);setDetailError('');if(selected)void Promise.resolve(client.rpc('admin_user_account',{p_profile:selected})).then(({data,error:problem})=>{if(!live)return;if(problem)throw problem;setDetail(data as Account);}).catch(e=>{if(live)setDetailError(errorMessage(e));});return()=>{live=false;};},[selected,identity.id,detailVersion]);
 useEffect(()=>setReason(''),[selected]);
 const filter=(action:()=>void)=>{action();setOffset(0);};
 async function changeStatus(){
  if(!detail||saving||!reason.trim())return;const account=detail,actor=identity.id,next=account.account_status==='active'?'suspended':'active';setSaving(true);
  try{const accepted=await confirmAction(next==='suspended'?'Suspend this account?':'Reactivate this account?',`${account.full_name}\n\n${next==='suspended'?'This account can continue browsing and planning trips. New bookings and reviews will be paused. Existing bookings and listings remain recorded.':'This account will regain access to TravelMate.'}\n\nReason: ${reason.trim()}`,next==='suspended'?'Suspend account':'Reactivate account','Keep current status');
   if(!accepted||currentIdentity().id!==actor||currentSelection.current!==account.id)return;
   const result=await client.rpc('admin_set_user_status',{p_profile:account.id,p_status:next,p_reason:reason.trim(),p_expected_updated_at:account.updated_at});if(result.error)throw result.error;
   if(currentIdentity().id!==actor)return;setVersion(v=>v+1);if(currentSelection.current===account.id){setDetail(result.data as Account);setReason('');}toast(next==='suspended'?'Account suspended successfully.':'Account reactivated successfully.');
  }catch(e){if(currentIdentity().id===actor)toast(errorMessage(e),true);}finally{if(currentIdentity().id===actor)setSaving(false);}
 }
 const protectedAccount=detail&&(detail.id===identity.id||detail.roles.includes('admin')||detail.account_status==='closed');
 return <div className="tm-page tm-user-management"><PageHeading eyebrow="ADMINISTRATION" title="User management" description="Find an account, review its activity, and manage access to TravelMate." action={<Button variant="outline" disabled={loading} onClick={()=>setVersion(v=>v+1)}><RefreshCw/>Refresh users</Button>}/>
  <nav className="tm-admin-local-nav" aria-label="Administration">
   {[{path:'/home',label:'Overview',icon:LayoutDashboard},{path:'/admin',label:'Listing reviews',icon:ClipboardCheck},{path:'/users',label:'User management',icon:Users},{path:'/reports',label:'Reports',icon:ChartNoAxesCombined}].map(({path,label,icon:Icon})=><a key={path} href={'#'+path} aria-current={path==='/users'?'page':undefined}><Icon size={19} aria-hidden="true"/>{label}</a>)}
  </nav>
  {directory&&<div className="tm-user-stats">{[{label:'All accounts',tone:'all',value:directory.counts.total,icon:Users,run:()=>{setRole('all');setStatus('all');setQuery('');},active:role==='all'&&status==='all'&&!query},{label:'Active',tone:'active',value:directory.counts.active,icon:UserCheck,run:()=>{setRole('all');setStatus('active');setQuery('');},active:status==='active'},{label:'Suspended',tone:'suspended',value:directory.counts.suspended,icon:UserX,run:()=>{setRole('all');setStatus('suspended');setQuery('');},active:status==='suspended'},{label:'Administrators',tone:'admin',value:directory.counts.admins,icon:Shield,run:()=>{setRole('admin');setStatus('all');setQuery('');},active:role==='admin'}].map(({label,tone,value,icon:Icon,run,active})=><button key={label} data-account-tone={tone} aria-pressed={active} onClick={()=>filter(run)}><Icon size={23}/><span><strong>{value}</strong><small>{label}</small></span>{active&&<span className="tm-user-stat-check" aria-hidden="true">✓</span>}</button>)}</div>}
  <AdminAppeals onDecision={()=>setVersion(v=>v+1)}/>
  <section className="tm-user-directory">
   <div className="tm-workspace-title"><div><h2>Account directory</h2><p>Open an account to see details and access history.</p></div></div>
   <div className="tm-user-filters">
    <label>Search users<span className="tm-workspace-search"><Search size={18}/><input type="search" maxLength={120} value={query} placeholder="Name or email address" onChange={e=>filter(()=>setQuery(e.target.value))}/></span></label>
    <FilterSelect label="Role" value={role} onChange={value=>filter(()=>setRole(value))} options={[{value:'all',label:'All roles'},{value:'traveler',label:'Traveler'},{value:'business_owner',label:'Business owner'},{value:'admin',label:'Administrator'}]}/>
    <FilterSelect label="Account status" value={status} onChange={value=>filter(()=>setStatus(value))} options={[{value:'all',label:'All statuses'},{value:'active',label:'Active'},{value:'suspended',label:'Suspended'},{value:'closed',label:'Closed'}]}/>
    <Button variant="outline" onClick={()=>filter(()=>{setQuery('');setRole('all');setStatus('all');})}>Clear filters</Button>
   </div>
   {error?<ErrorState message={error} retry={()=>setVersion(v=>v+1)}/>:loading?<LoadingCards/>:directory&&!directory.items.length?<EmptyState title="No matching accounts">Try another name or clear the filters.</EmptyState>:directory&&<>
    <div className="tm-table-scroll" role="region" aria-label="User accounts" tabIndex={0}>
     <table className="tm-workspace-table"><thead><tr><th scope="col">Account</th><th scope="col">Role</th><th scope="col">Status</th><th scope="col">Joined</th></tr></thead>
      <tbody>{directory.items.map(account=><tr key={account.id} className="tm-account-row" onClick={event=>{if(!(event.target as Element).closest('button'))setSelected(account.id);}}>
       <td><button aria-label={'Open account: '+(account.full_name||'Unnamed account')} onClick={()=>setSelected(account.id)}>{account.full_name||'Unnamed account'}<ArrowUpRight size={16}/></button><small>{account.email||'Email unavailable'}{account.id===identity.id?' · You':''}</small></td>
       <td data-label="Role">{roleLabel(account.roles)}</td><td data-label="Status"><span className={'tm-status tm-status-'+(account.account_status==='active'?'approved':account.account_status==='suspended'?'rejected':'inactive')} data-account-status={account.account_status}>{account.account_status}</span></td><td data-label="Joined">{date(account.created_at)}</td>
      </tr>)}</tbody>
     </table>
    </div>
    <PageNavigation page={offset/25} total={directory.total} pageSize={25} onChange={page=>setOffset(page*25)} label="User directory pages" noun="accounts"/>
   </>}
  </section>
  {selected&&<Modal title={detail?.full_name||'Account details'} close={()=>{if(!saving)setSelected(null);}} closeOnOutside className="tm-account-detail-modal"><div className="tm-account-detail-body">{detailError?<ErrorState message={detailError} retry={()=>setDetailVersion(v=>v+1)}/>:!detail?<LoadingCards/>:<><Button variant="outline" disabled={saving} onClick={()=>setDetailVersion(v=>v+1)}><RefreshCw/>Refresh account</Button><dl><div><dt>Email</dt><dd>{detail.email||'Unavailable'}</dd></div><div><dt>Role</dt><dd>{roleLabel(detail.roles)}</dd></div><div><dt>Account status</dt><dd><span className="tm-account-state" data-account-status={detail.account_status}>{detail.account_status}</span></dd></div><div><dt>Joined</dt><dd>{date(detail.created_at)}</dd></div><div><dt>Travel plans / bookings</dt><dd>{detail.trips} / {detail.bookings}</dd></div><div><dt>Business listings</dt><dd>{detail.listings}</dd></div></dl>
    {protectedAccount?<p className="tm-data-scope"><Shield size={16}/> {detail.roles.includes('admin')||detail.id===identity.id?'Administrator accounts are protected from suspension.':'This account is closed. Its access cannot be changed here.'}</p>:<form className="tm-account-status-form" data-next-status={detail.account_status==='active'?'suspended':'active'} onSubmit={e=>{e.preventDefault();void changeStatus();}}><label htmlFor="account-status-reason">Reason for {detail.account_status==='active'?'suspension':'reactivation'}</label><textarea id="account-status-reason" required maxLength={300} disabled={saving} value={reason} onChange={e=>setReason(e.target.value)} placeholder="Explain why this account’s access should change."/><p className="tm-data-scope">{reason.length}/300 · The change and reason will be recorded in account history.</p><Button variant={detail.account_status==='active'?'destructive':'default'} disabled={saving||!reason.trim()} type="submit">{detail.account_status==='active'?<TriangleAlert/>:<UserCheck/>}{saving?'Saving…':detail.account_status==='active'?'Suspend account':'Reactivate account'}</Button></form>}
    <section className="tm-account-access-history"><h3 className="flex items-center gap-2"><History size={20}/>Access history</h3>{detail.audit.length?<ul className="tm-audit-list">{detail.audit.map((entry,i)=><li key={i}><strong>{entry.previous_status} → {entry.next_status}</strong><p>{entry.reason}</p><small>{entry.actor_name} · {date(entry.created_at)}</small></li>)}</ul>:<p className="tm-data-scope">No access changes recorded.</p>}</section>
   </>}</div></Modal>}
 </div>;
}
