import {createPortal} from 'react-dom';
import {Toaster} from 'sonner';
/** Keep live feedback outside roots made inert by a dialog. */
export function ToastLayer(){
 return createPortal(<div data-toast-root=""><Toaster position="bottom-right" closeButton richColors/></div>,document.body);
}
